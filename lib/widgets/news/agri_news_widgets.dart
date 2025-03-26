import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/news/agri_news_controller.dart';

class AgricultureNewsSection extends StatelessWidget {
  const AgricultureNewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the AgricultureNewsController is registered.
    final AgricultureNewsController controller =
        Get.put(AgricultureNewsController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A27)),
          ));
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.newsList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No news available at the moment.'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'AGRICULTURE NEWS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A27),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            // Horizontal list of expandable news cards.
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.newsList.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 16.0),
                    child: ExpandableNewsCard(
                        newsItem: controller.newsList[index]),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class ExpandableNewsCard extends StatefulWidget {
  final Map<String, dynamic> newsItem;

  const ExpandableNewsCard({Key? key, required this.newsItem})
      : super(key: key);

  @override
  _ExpandableNewsCardState createState() => _ExpandableNewsCardState();
}

class _ExpandableNewsCardState extends State<ExpandableNewsCard> {
  bool isExpanded = false;
  final double initialCardHeight = 165.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFACE268),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A27).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF2D5A27).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // News header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4BE),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF2D5A27),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.article_outlined,
                      color: Color(0xFF2D5A27),
                      size: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF2D5A27),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // News content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: isExpanded
                        ? const BoxConstraints()
                        : const BoxConstraints(maxHeight: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.newsItem['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A27),
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.newsItem['description'] ??
                              'No description available',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: isExpanded ? null : 4,
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        if (isExpanded && widget.newsItem['url'] != null) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton.icon(
                              icon: const Icon(
                                Icons.open_in_new,
                                size: 16,
                                color: Color(0xFF2D5A27),
                              ),
                              label: const Text(
                                'Read More',
                                style: TextStyle(
                                  color: Color(0xFF2D5A27),
                                ),
                              ),
                              onPressed: () {
                                // Open URL
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
