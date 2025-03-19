import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/campaign/jobPost_controller.dart';
import 'package:lencho/controllers/campaign/campPost_controller.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double verticalSpace = screenHeight * 0.02;
    final double textFieldWidth = screenWidth * 0.85;
    final double buttonHeight = screenHeight * 0.06;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post a Campaign or Job'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Campaign'),
              Tab(text: 'Job'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Campaign posting form
            SingleChildScrollView(
              padding: EdgeInsets.all(verticalSpace),
              child: Form(
                key: _campaignFormKey,
                child: Column(
                  children: [
                    // Campaign Title Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: campaignTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Campaign Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a campaign title';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace),
                    // Organisation Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: campaignOrganisationController,
                        decoration: const InputDecoration(
                          labelText: 'Organisation',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an organisation';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace),
                    // Location Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: campaignLocationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace),
                    // Details Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: campaignDetailsController,
                        decoration: const InputDecoration(
                          labelText: 'Details',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter campaign details';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace * 1.5),
                    // Submit Button
                    SizedBox(
                      width: textFieldWidth,
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
                            // Clear the form fields after posting.
                            campaignTitleController.clear();
                            campaignOrganisationController.clear();
                            campaignLocationController.clear();
                            campaignDetailsController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Post Campaign',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                    // Job Title Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: jobTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Job Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a job title';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace),
                    // Organisation Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: jobOrganisationController,
                        decoration: const InputDecoration(
                          labelText: 'Organisation',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an organisation';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace),
                    // Location Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: jobLocationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace),
                    // Salary Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: jobSalaryController,
                        decoration: const InputDecoration(
                          labelText: 'Salary per Week',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the salary';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace),
                    // Details Field
                    SizedBox(
                      width: textFieldWidth,
                      child: TextFormField(
                        controller: jobDetailsController,
                        decoration: const InputDecoration(
                          labelText: 'Details',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter job details';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: verticalSpace * 1.5),
                    // Submit Button
                    SizedBox(
                      width: textFieldWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_jobFormKey.currentState!.validate()) {
                            // Convert the salary string to a double.
                            double salary = double.tryParse(jobSalaryController.text.trim()) ?? 0.0;
                            await jobController.postJob(
                              title: jobTitleController.text.trim(),
                              organisation: jobOrganisationController.text.trim(),
                              location: jobLocationController.text.trim(),
                              salaryPerWeek: salary,
                              details: jobDetailsController.text.trim(),
                            );
                            // Clear the form fields after posting.
                            jobTitleController.clear();
                            jobOrganisationController.clear();
                            jobLocationController.clear();
                            jobSalaryController.clear();
                            jobDetailsController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Post Job',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
