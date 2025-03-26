import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/campaign/jobPost_controller.dart';
import 'package:lencho/models/job.dart';

class JobsSection extends StatelessWidget {
  const JobsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the JobController is registered.
    final JobController controller = Get.put(JobController());

    return StreamBuilder<List<Job>>(
      stream: controller.streamJobs(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading jobs: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A27)),
          ));
        }
        final jobs = snapshot.data!;
        if (jobs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No jobs posted yet.'),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'JOBS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A27),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // Horizontal list of expandable job cards.
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16.0),
                      child: ExpandableJobCard(job: jobs[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExpandableJobCard extends StatefulWidget {
  final Job job;

  const ExpandableJobCard({Key? key, required this.job}) : super(key: key);

  @override
  _ExpandableJobCardState createState() => _ExpandableJobCardState();
}

class _ExpandableJobCardState extends State<ExpandableJobCard> {
  bool isExpanded = false;
  final double collapsedHeight = 146.0;

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
              Color(0xFFE8F4FF),
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
          child: Container(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job header
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
                          widget.job.title,
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

                // Job content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: isExpanded
                        ? const BoxConstraints()
                        : BoxConstraints(maxHeight: 120),
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
                                widget.job.organisation,
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
                                widget.job.location,
                                style: const TextStyle(
                                  fontSize: 14,
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
                              Icons.paid,
                              size: 16,
                              color: Color(0xFF2D5A27),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "₹${widget.job.salaryPerWeek.toStringAsFixed(2)}/week",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D5A27),
                              ),
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 16),
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
                            widget.job.details,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
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
                                child: const Text('Apply Now'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
