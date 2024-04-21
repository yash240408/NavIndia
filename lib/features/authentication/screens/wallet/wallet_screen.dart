import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class CustomerWalletScreen extends StatelessWidget {
   const CustomerWalletScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
      var sharedPref = GetStorage();
      sharedPref.initStorage;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rewards_details')
            .where('assignUserId', isEqualTo: sharedPref.read("userId"))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              return _buildCouponCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> data) {
//   DateTime expiryDate = DateFormat("d MMMM yyyy 'at' HH:mm:ss 'UTC'Z").parse(data["validationDate"]);
// int remainingDays = expiryDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(10),
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              '${data["productName"]}',
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original Price: ${data["originalPrice"]}',
                  style: const TextStyle(color: Colors.red),
                ),
                Text(
                  'Discounted Price: ${data["discountedPrice"]}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Redeem at: ${data["shopAddress"]}'),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop Address: ${data["shopAddress"]}',
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
