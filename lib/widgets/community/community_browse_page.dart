import 'dart:convert'; // For base64Decode
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'community_create_page.dart';
import 'community_detail_page.dart';
import 'community_search_delegate.dart';
import 'package:lencho/widgets/home/header_widgets.dart'; // Adjust the path as needed

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
      // Remove the default AppBar.
      backgroundColor: const Color.fromRGBO(245, 247, 255, 1),
      body: Column(
        children: [
          // Insert the custom header.
          const HomeHeader(isHome: false),
          // Add a search bar below the header.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: InkWell(
              onTap: () => _showSearchDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A27).withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFACE268).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.search,
                      color: Color(0xFF2D5A27),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Search communities...',
                      style: TextStyle(
                        color: Color(0xFF2D5A27),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Use Expanded to fill the remaining space with the list.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                          onPressed: () =>
                              Get.to(() => const CommunityCreatePage()),
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
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 4,
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
                              // Use imageContent (Base64 encoded) if available.
                              backgroundImage: data['imageContent'] != null
                                  ? MemoryImage(
                                      base64Decode(data['imageContent']),
                                    )
                                  : null,
                              radius: 22,
                              child: data['imageContent'] == null
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
          ),
        ],
      ),
    );
  }
}
