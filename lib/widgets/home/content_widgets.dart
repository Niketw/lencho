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
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF4BE),
                        Color(0xFFACE268),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A27).withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.people_alt_rounded,
                            color: Color(0xFF2D5A27),
                            size: 24,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Community Updates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D5A27),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF2D5A27),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Dashboard Section Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'DASHBOARD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A27),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Dashboard Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDashboardItem(
                      title: 'Disease Detection',
                      icon: Icons.healing,
                      onTap: () => Get.to(() => DiseaseDetectionWidget()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDashboardItem(
                      title: 'Irrigation Plan',
                      icon: Icons.water_drop,
                      onTap: () => Get.to(() => const IrrigationPlanForm()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dynamic Campaigns Section
            const CampaignsSection(),

            const SizedBox(height: 16),

            // Jobs Section
            const JobsSection(),

            const SizedBox(height: 16),

            // Dynamic Agriculture News Section
            const AgricultureNewsSection(),

            // Add some bottom padding
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4BE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2D5A27).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2D5A27),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D5A27),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
