import tensorflow as tf
from tensorflow.keras.layers import Input, Dense, GlobalAveragePooling2D, Conv2D, MaxPooling2D, concatenate, Dropout, \
    Average, BatchNormalization
from tensorflow.keras.models import Model
from tensorflow.keras.applications import InceptionV3
from tensorflow.keras.applications.inception_v3 import preprocess_input as inception_preprocess
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import os

# Enable GPU growth and list GPUs
gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print(f"GPUs found: {[gpu.name for gpu in gpus]}")
    except RuntimeError as e:
        print(e)

# Use MirroredStrategy to utilize all available GPUs
strategy = tf.distribute.MirroredStrategy()
print('Number of devices: {}'.format(strategy.num_replicas_in_sync))

# ----------------------------
# Functions to Build Model Branches
# ----------------------------
def build_inceptionv3_branch(input_tensor):
    base_model = InceptionV3(weights='imagenet', include_top=False, input_tensor=input_tensor)
    for layer in base_model.layers:
        layer.trainable = False
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dropout(0.5)(x)
    x = Dense(512, activation='relu')(x)
    return x


def inception_module(x, filters_1x1, filters_3x3_reduce, filters_3x3,
                     filters_5x5_reduce, filters_5x5, filters_pool_proj):
    branch1 = Conv2D(filters_1x1, (1, 1), padding='same', activation='relu')(x)
    branch2 = Conv2D(filters_3x3_reduce, (1, 1), padding='same', activation='relu')(x)
    branch2 = Conv2D(filters_3x3, (3, 3), padding='same', activation='relu')(branch2)
    branch3 = Conv2D(filters_5x5_reduce, (1, 1), padding='same', activation='relu')(x)
    branch3 = Conv2D(filters_5x5, (5, 5), padding='same', activation='relu')(branch3)
    branch4 = MaxPooling2D((3, 3), strides=(1, 1), padding='same')(x)
    branch4 = Conv2D(filters_pool_proj, (1, 1), padding='same', activation='relu')(branch4)
    output = concatenate([branch1, branch2, branch3, branch4], axis=-1)
    return output


def build_googlenet_branch(input_tensor):
    x = Conv2D(64, (7, 7), strides=(2, 2), padding='same', activation='relu')(input_tensor)
    x = MaxPooling2D((3, 3), strides=(2, 2), padding='same')(x)
    x = BatchNormalization()(x)
    x = Conv2D(64, (1, 1), padding='same', activation='relu')(x)
    x = Conv2D(192, (3, 3), padding='same', activation='relu')(x)
    x = BatchNormalization()(x)
    x = MaxPooling2D((3, 3), strides=(2, 2), padding='same')(x)
    x = inception_module(x, 64, 96, 128, 16, 32, 32)
    x = inception_module(x, 128, 128, 192, 32, 96, 64)
    x = MaxPooling2D((3, 3), strides=(2, 2), padding='same')(x)
    x = inception_module(x, 192, 96, 208, 16, 48, 64)
    x = GlobalAveragePooling2D()(x)
    x = Dropout(0.5)(x)
    x = Dense(512, activation='relu')(x)
    return x


# ----------------------------
# Preprocessing Function
# ----------------------------
def preprocess(image, label):
    image = inception_preprocess(image)
    return image, label


# ----------------------------
# Training Parameters
# ----------------------------
batch_size = 32
img_height = 299
img_width = 299
validation_split = 0.2
seed = 123
epochs = 30

# Base directory for dataset
base_data_dir = './Datasets/plant-diseases-sorted-original'

# Directory to store models and class files
models_dir = "./Models-original"
os.makedirs(models_dir, exist_ok=True)

# List all plants
plant_list = [d for d in os.listdir(base_data_dir) if os.path.isdir(os.path.join(base_data_dir, d))]
print("Plants found:", plant_list)

# Loop over each plant to train a specific model
for plant in plant_list:
    print(f"\nProcessing plant: {plant}")

    # Create a subfolder for each plant inside Models
    plant_model_dir = os.path.join(models_dir, plant)
    os.makedirs(plant_model_dir, exist_ok=True)

    # Dataset path for this plant
    plant_data_dir = os.path.join(base_data_dir, plant)

    try:
        original_train_ds = tf.keras.preprocessing.image_dataset_from_directory(
            plant_data_dir,
            validation_split=validation_split,
            subset="training",
            seed=seed,
            image_size=(img_height, img_width),
            batch_size=batch_size,
            label_mode='categorical'
        )

        original_val_ds = tf.keras.preprocessing.image_dataset_from_directory(
            plant_data_dir,
            validation_split=validation_split,
            subset="validation",
            seed=seed,
            image_size=(img_height, img_width),
            batch_size=batch_size,
            label_mode='categorical'
        )
    except Exception as e:
        print(f"Error loading data for {plant}: {e}")
        continue

    total_train_samples = len(original_train_ds.file_paths)
    total_val_samples = len(original_val_ds.file_paths)
    class_names = original_train_ds.class_names
    num_classes = len(class_names)

    print(f"Classes for {plant}: {class_names}")
    print(f"Total training samples: {total_train_samples}")
    print(f"Total validation samples: {total_val_samples}")

    # Save class names
    class_file_path = os.path.join(plant_model_dir, f"{plant}_classes.txt")
    with open(class_file_path, "w") as f:
        f.write(", ".join(f"'{cls}'" for cls in class_names))

    # Preprocessing
    train_ds = original_train_ds.map(preprocess, num_parallel_calls=tf.data.AUTOTUNE)
    val_ds = original_val_ds.map(preprocess, num_parallel_calls=tf.data.AUTOTUNE)
    train_ds = train_ds.unbatch().batch(batch_size, drop_remainder=True).prefetch(buffer_size=tf.data.AUTOTUNE)
    val_ds = val_ds.unbatch().batch(batch_size, drop_remainder=True).prefetch(buffer_size=tf.data.AUTOTUNE)

    # ----------------------------
    # Build and Compile the Model
    # ----------------------------
    with strategy.scope():
        input_tensor = Input(shape=(img_height, img_width, 3))
        branch1 = build_inceptionv3_branch(input_tensor)
        branch2 = build_googlenet_branch(input_tensor)
        combined = Average()([branch1, branch2])
        output_tensor = Dense(num_classes, activation='softmax')(combined)

        model = Model(inputs=input_tensor, outputs=output_tensor)
        model.compile(optimizer=Adam(learning_rate=1e-4),
                      loss='categorical_crossentropy',
                      metrics=['accuracy'])

    model_checkpoint_path = os.path.join(plant_model_dir, f"{plant}_best_model.keras")
    final_model_path = os.path.join(plant_model_dir, f"{plant}_disease_model.h5")

    # ----------------------------
    # Train the Model
    # ----------------------------
    callbacks = [
        EarlyStopping(monitor='val_accuracy', patience=3, restore_best_weights=True),
        ModelCheckpoint(model_checkpoint_path, monitor='val_accuracy', save_best_only=True)
    ]

    history = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=epochs,
        callbacks=callbacks,
        verbose=1
    )

    # Save the final trained model
    model.save(final_model_path, save_format="h5")
    print(f"Saved model for {plant} at {final_model_path}")
