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
          return const Center(child: CircularProgressIndicator());
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
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Jobs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Horizontal list of expandable job cards.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: jobs.map((job) {
                    return Container(
                      width: 300, // Fixed width for each card.
                      margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                      child: ExpandableJobCard(job: job),
                    );
                  }).toList(),
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
  // Set a fixed collapsed height to show:
  // - Title (2 lines)
  // - Company (1 line)
  // - Location (1 line)
  final double collapsedHeight = 146.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        elevation: 2,
        // Use a color scheme similar to your news section.
        color: const Color(0xFFE8F4FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF2D5A27),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 300, // Fixed width for every card.
            // When collapsed, constrain the height; when expanded, let content dictate height.
            child: ConstrainedBox(
              constraints: isExpanded
                  ? const BoxConstraints()
                  : BoxConstraints(maxHeight: collapsedHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Title in bold (1 lines max when collapsed)
                  Text(
                    widget.job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: isExpanded ? null : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Company (non-bold, single line)
                  Text(
                    widget.job.organisation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Location (non-bold, single line)
                  Text(
                    widget.job.location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.job.salaryPerWeek.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Expand/Collapse arrow button.
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                    ),
                  ),
                  // When expanded, show job details.
                  if (isExpanded) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.details,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
