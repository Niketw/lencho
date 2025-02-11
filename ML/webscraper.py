#!/usr/bin/env python3
import os
import glob
from icrawler.builtin import GoogleImageCrawler, BingImageCrawler

def count_images(folder, extensions=('.jpg', '.jpeg', '.png')):
    """Count the number of images in folder with given extensions."""
    count = 0
    for ext in extensions:
        count += len(glob.glob(os.path.join(folder, f'*{ext}')))
    return count

# List of classes in the format <plant_name>__<disease_name>
classes = [
    'Apple__black_rot','Apple__healthy','Apple__rust','Apple__scab',
    'Cassava__bacterial_blight','Cassava__brown_streak_disease','Cassava__green_mottle','Cassava__healthy','Cassava__mosaic_disease',
    'Cherry__healthy','Cherry__powdery_mildew',
    'Chili__healthy','Chili__leaf curl','Chili__leaf spot','Chili__whitefly','Chili__yellowish',
    'Coffee__cercospora_leaf_spot','Coffee__healthy','Coffee__red_spider_mite','Coffee__rust',
    'Corn__common_rust','Corn__gray_leaf_spot','Corn__healthy','Corn__northern_leaf_blight',
    'Cucumber__diseased','Cucumber__healthy',
    'Gauva__diseased','Gauva__healthy',
    'Grape__black_measles','Grape__black_rot','Grape__healthy','Grape__leaf_blight_(isariopsis_leaf_spot)',
    'Jamun__diseased','Jamun__healthy',
    'Lemon__diseased','Lemon__healthy',
    'Mango__diseased','Mango__healthy',
    'Peach__bacterial_spot','Peach__healthy',
    'Pepper_bell__bacterial_spot','Pepper_bell__healthy',
    'Pomegranate__diseased','Pomegranate__healthy',
    'Potato__early_blight','Potato__healthy','Potato__late_blight',
    'Rice__brown_spot','Rice__healthy','Rice__hispa','Rice__leaf_blast','Rice__neck_blast',
    'Soybean__bacterial_blight','Soybean__caterpillar','Soybean__diabrotica_speciosa','Soybean__downy_mildew','Soybean__healthy','Soybean__mosaic_virus','Soybean__powdery_mildew','Soybean__rust','Soybean__southern_blight',
    'Strawberry___leaf_scorch','Strawberry__healthy',
    'Sugarcane__bacterial_blight','Sugarcane__healthy','Sugarcane__red_rot','Sugarcane__red_stripe','Sugarcane__rust',
    'Tea__algal_leaf','Tea__anthracnose','Tea__bird_eye_spot','Tea__brown_blight','Tea__healthy','Tea__red_leaf_spot',
    'Tomato__bacterial_spot','Tomato__early_blight','Tomato__healthy','Tomato__late_blight','Tomato__leaf_mold','Tomato__mosaic_virus','Tomato__septoria_leaf_spot','Tomato__spider_mites_(two_spotted_spider_mite)','Tomato__target_spot','Tomato__yellow_leaf_curl_virus',
    'Wheat__brown_rust','Wheat__healthy','Wheat__septoria','Wheat__yellow_rust'
]

# Base directory where images will be stored
base_dir = "dataset"
os.makedirs(base_dir, exist_ok=True)

max_images = 50  # desired images per class

for cls in classes:
    # Create folder for this class
    class_folder = os.path.join(base_dir, cls)
    os.makedirs(class_folder, exist_ok=True)

    # Build search queries:
    parts = cls.split('__')
    if len(parts) >= 2:
        plant_name = parts[0]
        disease_name = parts[1]
        # Create two query variations:
        query_primary = f"{plant_name} {disease_name.replace('_', ' ')} leaf"
        query_fallback = f"{plant_name} {disease_name.replace('_', ' ')}"
    else:
        query_primary = f"{cls} leaf"
        query_fallback = cls

    print(f"\n[INFO] Querying for class '{cls}' with primary query: '{query_primary}'")

    # First, use Google Image Crawler with the primary query.
    google_crawler = GoogleImageCrawler(storage={'root_dir': class_folder})
    google_crawler.crawl(keyword=query_primary,
                         max_num=max_images,
                         min_size=(200, 200),
                         file_idx_offset=0)

    downloaded = count_images(class_folder)
    if downloaded < max_images:
        missing = max_images - downloaded
        print(f"[INFO] Only {downloaded} images found for '{cls}'. Trying fallback query: '{query_fallback}' for {missing} additional images.")
        google_crawler.crawl(keyword=query_fallback,
                             max_num=missing,
                             min_size=(200, 200),
                             file_idx_offset=downloaded)
        downloaded = count_images(class_folder)

    # If still not enough, try using Bing as an alternative source.
    if downloaded < max_images:
        missing = max_images - downloaded
        print(f"[INFO] Still only {downloaded} images for '{cls}'. Trying Bing crawler for {missing} additional images.")
        bing_crawler = BingImageCrawler(storage={'root_dir': class_folder})
        bing_crawler.crawl(keyword=query_fallback,
                           max_num=missing,
                           min_size=(200, 200),
                           file_idx_offset=downloaded)
        downloaded = count_images(class_folder)

    print(f"[INFO] Completed '{cls}'. Total images downloaded: {downloaded}")
