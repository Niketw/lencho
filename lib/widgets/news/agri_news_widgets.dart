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
            // Horizontal list of expandable news cards with fixed height
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.newsList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
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
  final double collapsedHeight = 165.0;
  final double expandedHeight = 300.0; // Reasonable expanded height

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: isExpanded ? expandedHeight : collapsedHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFF4BE),
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
            // News header (matches campaign header style)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFACE268),
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
                  Expanded(
                    child: Text(
                      widget.newsItem['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A27),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
            // News content area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.newsItem['description'] ??
                            'No description available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2D5A27),
                        ),
                        maxLines: isExpanded ? null : 4,
                        overflow: isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (isExpanded && widget.newsItem['url'] != null) ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Open URL logic goes here.
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D5A27),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Read More'),
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
    );
  }
}
