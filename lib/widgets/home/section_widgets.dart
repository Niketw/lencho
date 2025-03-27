import 'package:flutter/material.dart';

class ScrollableSection extends StatelessWidget {
  final String title;
  final List<SectionItem> items;

  const ScrollableSection({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        // Use SizedBox with a fixed height to contain the ListView
        SizedBox(
          height: 180, // Fixed height that accommodates your cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ExpandableSectionCard(item: items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ExpandableSectionCard extends StatefulWidget {
  final SectionItem item;

  const ExpandableSectionCard({Key? key, required this.item}) : super(key: key);

  @override
  _ExpandableSectionCardState createState() => _ExpandableSectionCardState();
}

class _ExpandableSectionCardState extends State<ExpandableSectionCard> {
  bool isExpanded = false;
  // Define fixed heights for collapsed and expanded states.
  final double collapsedHeight = 100.0;
  final double expandedHeight = 250.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: isExpanded ? expandedHeight : collapsedHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2D5A27),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.item.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title text (2 lines max when collapsed)
                Text(
                  widget.item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isExpanded ? null : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.item.details != null) ...[
                  const SizedBox(height: 8),
                  // Expand/Collapse arrow button.
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                    ),
                  ),
                  if (isExpanded)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.item.details!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionItem {
  final String title;
  final String? details;
  final VoidCallback onTap;

  const SectionItem({
    required this.title,
    this.details,
    required this.onTap,
  });
}

