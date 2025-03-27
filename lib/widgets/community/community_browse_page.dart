import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'community_create_page.dart';
import 'community_detail_page.dart';
import 'community_search_delegate.dart';

class CommunityBrowsePage extends StatelessWidget {
  const CommunityBrowsePage({Key? key}) : super(key: key);

  void _showSearchDialog(BuildContext context) {
    showSearch(
      context: context,
      delegate: CommunitySearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Lighter AppBar with the accent green from your theme.
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(172, 226, 103, 1),
        title: const Text(
          'Communities',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Color(0xFF2D5A27),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D5A27)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const CommunityCreatePage()),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      // Use the light background from the main page.
      backgroundColor: const Color.fromRGBO(245, 247, 255, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .orderBy('memberCount', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No communities found',
                    style: TextStyle(
                      color: Color(0xFF2D5A27),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFACE268),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Get.to(() => const CommunityCreatePage()),
                    child: const Text(
                      'Create a Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4, // Increased elevation to help the card pop.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: const Color(0xFFACE268).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(245, 247, 255, 1),
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFACE268),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: data['imageUrl'] != null
                            ? NetworkImage(data['imageUrl'])
                            : null,
                        radius: 22,
                        child: data['imageUrl'] == null
                            ? Text(
                                data['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF2D5A27),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    title: Text(
                      data['name'],
                      style: const TextStyle(
                        color: Color(0xFF2D5A27),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      data['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF2D5A27)),
                    ),
                    trailing: Text(
                      '${data['memberCount']} members',
                      style: const TextStyle(
                        color: Color(0xFF2D5A27),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => Get.to(() => CommunityDetailPage(
                          communityId: doc.id,
                          communityData: data,
                        )),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
