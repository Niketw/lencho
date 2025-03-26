import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/widgets/campaign/job_widget.dart';
import 'package:lencho/widgets/home/section_widgets.dart';
import 'package:lencho/widgets/campaign/campaign_widget.dart';
import 'package:lencho/widgets/news/agri_news_widgets.dart';
import 'package:lencho/screens/community/community_browse_page.dart';
import 'package:lencho/widgets/disease/disease_widget.dart';
import 'package:lencho/widgets/irrigation/irrigation_form_widgets.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Updates Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  Get.to(() => const CommunityBrowsePage());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2D5A27),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Community Updates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.chat_bubble_outline),
                    ],
                  ),
                ),
              ),
            ),

            // Dashboard Section
            ScrollableSection(
              title: 'DASHBOARD',
              items: [
                SectionItem(
                  title: 'Disease Detection',
                  onTap: () {
                    // Navigate to DiseaseDetectionWidget
                    Get.to(() => DiseaseDetectionWidget());
                  },
                ),
                SectionItem(
                  title: 'Irrigation Plan',
                  onTap: () {
                    Get.to(() => const IrrigationPlanForm());
                  },
                ),
              ],
            ),

            // Dynamic Campaigns Section
            const CampaignsSection(),

            const JobsSection(),

            // Dynamic Agriculture News Section
            const AgricultureNewsSection(),
          ],
        ),
      ),
    );
  }
}
