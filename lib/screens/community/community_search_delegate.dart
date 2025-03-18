import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lencho/screens/community/community_detail_page.dart';

class CommunitySearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
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
          return const Center(
            child: Text('No communities found'),
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
              onTap: () {
                close(context, null);
                Get.to(() => CommunityDetailPage(
                      communityId: doc.id,
                      communityData: data,
                    ));
              },
            );
          },
        );
      },
    );
  }
}
