import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/campaign/campPost_controller.dart';
import 'package:lencho/models/campaign.dart';

class CampaignsSection extends StatelessWidget {
  const CampaignsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the CampaignController is registered.
    final CampaignController controller = Get.put(CampaignController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<List<Campaign>>(
        stream: controller.streamCampaigns(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading campaigns: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A27)),
            ));
          }
          final campaigns = snapshot.data!;
          if (campaigns.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No campaigns posted yet.'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'CAMPAIGNS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A27),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Horizontal list of expandable campaign cards with fixed height
              SizedBox(
                height: 220, // Fixed height to prevent overflow
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ExpandableCampaignCard(campaign: campaigns[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExpandableCampaignCard extends StatefulWidget {
  final Campaign campaign;

  const ExpandableCampaignCard({Key? key, required this.campaign})
      : super(key: key);

  @override
  _ExpandableCampaignCardState createState() => _ExpandableCampaignCardState();
}

class _ExpandableCampaignCardState extends State<ExpandableCampaignCard> {
  bool isExpanded = false;
  final double collapsedHeight = 146.0;
  final double expandedHeight = 300.0; // Set a reasonable expanded height

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
            // Campaign header
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
                      widget.campaign.title,
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

            // Campaign content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 16,
                            color: Color(0xFF2D5A27),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.campaign.organisation,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF2D5A27),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.campaign.location,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isExpanded) ...[
                        const Text(
                          'Details:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A27),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.campaign.details,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {},
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
                            child: const Text('Join Campaign'),
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

