import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/campaign/campPost_controller.dart';
import 'package:lencho/controllers/campaign/jobPost_controller.dart';
import 'package:lencho/widgets/home/header_widgets.dart'; // Adjust the path as needed

class PostingWidget extends StatelessWidget {
  PostingWidget({Key? key}) : super(key: key);

  // Controllers for campaign posting
  final CampaignController campaignController = Get.put(CampaignController());
  final GlobalKey<FormState> _campaignFormKey = GlobalKey<FormState>();
  final TextEditingController campaignTitleController = TextEditingController();
  final TextEditingController campaignOrganisationController = TextEditingController();
  final TextEditingController campaignLocationController = TextEditingController();
  final TextEditingController campaignDetailsController = TextEditingController();

  // Controllers for job posting
  final JobController jobController = Get.put(JobController());
  final GlobalKey<FormState> _jobFormKey = GlobalKey<FormState>();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController jobOrganisationController = TextEditingController();
  final TextEditingController jobLocationController = TextEditingController();
  final TextEditingController jobSalaryController = TextEditingController();
  final TextEditingController jobDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive spacing.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double verticalSpace = screenHeight * 0.02;
    final double buttonHeight = screenHeight * 0.06;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 247, 255, 1),
        body: Column(
          children: [
            // Custom header (back button, logo/title, language toggle)
            const HomeHeader(isHome: false),
            // TabBar placed in a container to style it appropriately.
            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Color(0xFF2D5A27),
                labelColor: Color(0xFF2D5A27),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Campaign'),
                  Tab(text: 'Job'),
                ],
              ),
            ),
            // Expanded TabBarView for the posting forms.
            Expanded(
              child: TabBarView(
                children: [
                  // Campaign posting form
                  SingleChildScrollView(
                    padding: EdgeInsets.all(verticalSpace),
                    child: Form(
                      key: _campaignFormKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: campaignTitleController,
                            label: 'Campaign Title',
                            icon: Icons.campaign,
                          ),
                          SizedBox(height: verticalSpace),
                          _buildTextField(
                            controller: campaignOrganisationController,
                            label: 'Organisation',
                            icon: Icons.business,
                          ),
                          SizedBox(height: verticalSpace),
                          _buildTextField(
                            controller: campaignLocationController,
                            label: 'Location',
                            icon: Icons.location_on,
                          ),
                          SizedBox(height: verticalSpace),
                          _buildTextField(
                            controller: campaignDetailsController,
                            label: 'Details',
                            icon: Icons.description,
                            maxLines: 4,
                          ),
                          SizedBox(height: verticalSpace * 1.5),
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_campaignFormKey.currentState!.validate()) {
                                  await campaignController.postCampaign(
                                    title: campaignTitleController.text.trim(),
                                    organisation: campaignOrganisationController.text.trim(),
                                    location: campaignLocationController.text.trim(),
                                    details: campaignDetailsController.text.trim(),
                                  );
                                  _clearFields([
                                    campaignTitleController,
                                    campaignOrganisationController,
                                    campaignLocationController,
                                    campaignDetailsController,
                                  ]);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: Colors.green[700],
                              ),
                              child: const Text(
                                'Post Campaign',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Job posting form
                  SingleChildScrollView(
                    padding: EdgeInsets.all(verticalSpace),
                    child: Form(
                      key: _jobFormKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: jobTitleController,
                            label: 'Job Title',
                            icon: Icons.work,
                          ),
                          SizedBox(height: verticalSpace),
                          _buildTextField(
                            controller: jobOrganisationController,
                            label: 'Organisation',
                            icon: Icons.business,
                          ),
                          SizedBox(height: verticalSpace),
                          _buildTextField(
                            controller: jobLocationController,
                            label: 'Location',
                            icon: Icons.location_on,
                          ),
                          SizedBox(height: verticalSpace),
                          _buildTextField(
                            controller: jobSalaryController,
                            label: 'Salary per Week',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: verticalSpace),
                          _buildTextField(
                            controller: jobDetailsController,
                            label: 'Details',
                            icon: Icons.description,
                            maxLines: 4,
                          ),
                          SizedBox(height: verticalSpace * 1.5),
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_jobFormKey.currentState!.validate()) {
                                  double salary = double.tryParse(jobSalaryController.text.trim()) ?? 0.0;
                                  await jobController.postJob(
                                    title: jobTitleController.text.trim(),
                                    organisation: jobOrganisationController.text.trim(),
                                    location: jobLocationController.text.trim(),
                                    salaryPerWeek: salary,
                                    details: jobDetailsController.text.trim(),
                                  );
                                  _clearFields([
                                    jobTitleController,
                                    jobOrganisationController,
                                    jobLocationController,
                                    jobSalaryController,
                                    jobDetailsController,
                                  ]);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: Colors.green[700],
                              ),
                              child: const Text(
                                'Post Job',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a styled text field.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green[700]),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter $label' : null,
    );
  }

  /// Helper method to clear all provided controllers.
  void _clearFields(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.clear();
    }
  }
}
