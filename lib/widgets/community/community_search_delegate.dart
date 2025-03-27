import 'dart:convert'; // For base64Decode
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'community_detail_page.dart';

class CommunitySearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }
  
  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a community name or tag to search'),
      );
    }
    
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('communities')
          .where('tags', arrayContains: query.toLowerCase())
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No communities found'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
                    onTap: () {
                      close(context, null);
                      Get.to(() => CommunityDetailPage(
                            communityId: doc.id,
                            communityData: data,
                          ));
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
