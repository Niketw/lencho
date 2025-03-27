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
      appBar: AppBar(
        title: const Text('Communities'),
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
                  const Text('No communities found'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const CommunityCreatePage()),
                    child: const Text('Create a Community'),
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

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: data['imageUrl'] != null
                      ? NetworkImage(data['imageUrl'])
                      : null,
                  child: data['imageUrl'] == null
                      ? Text(data['name'][0].toUpperCase())
                      : null,
                ),
                title: Text(data['name']),
                subtitle: Text(
                  data['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text('${data['memberCount']} members'),
                onTap: () => Get.to(() => CommunityDetailPage(
                      communityId: doc.id,
                      communityData: data,
                    )),
              );
            },
          );
        },
      ),
    );
  }
}
