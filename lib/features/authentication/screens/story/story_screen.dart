import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
class StoryScreen extends StatelessWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pothole_details')
            .where('status', isEqualTo: "verified")
            .where('story_added_time',
                isGreaterThanOrEqualTo:
                    DateTime.now().subtract(const Duration(days: 1)))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No potholes found in the last 24 hours'),
            );
          } else {
            // Data is loaded, build the UI
            return _buildPotholeList(snapshot.data!.docs);
          }
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Number of shimmer items
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 56.0,
              height: 56.0,
              color: Colors.white,
            ),
            title: Container(
              height: 16.0,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 16.0,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

 Widget _buildPotholeList(List<QueryDocumentSnapshot> documents) {
  return ListView.builder(
    itemCount: documents.length,
    itemBuilder: (context, index) {
      // Extract data from the document
      String imageLink = documents[index]['imagePath'];
      String itemAddress = documents[index]['address'];
      String itemDescription = documents[index]['description'];

      // Retrieve user details using the userId
      String userId = documents[index]['userId'];

      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user_details')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListTile(
              leading: Container(
                width: 56.0,
                height: 56.0,
                color: Colors.white,
              ),
              title: Container(
                height: 16.0,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 16.0,
                color: Colors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return ListTile(
              title: Text('Error: ${snapshot.error}'),
            );
          } else {
            dynamic userData = snapshot.data!.data();
            String userName = userData!["fullname"];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: Colors.black,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: Get.width * 0.95,
                            height: Get.width * 0.6, // Adjust the height as needed
                            child: Image.network(
                              imageLink,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                          if (imageLink
                              .isEmpty) // Show placeholder if image link is empty
                            const Icon(Icons.image, size: 40),
                        ],
                      ),
                    ),

                    ListTile(
                      title: Column(
                        children: [
                          Text(
                            userName.capitalize!,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        children: [
                          Text(
                            "\n$itemDescription\n\nLocation: $itemAddress",
                            style: const TextStyle(
                              color: Colors.grey,
                            ),textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    },
  );
}
}
