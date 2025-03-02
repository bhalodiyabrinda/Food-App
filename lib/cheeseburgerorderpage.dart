import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'paymentpage.dart'; // Make sure this matches the filename
import 'databasefood.dart'; // Ensure this file exists and is correctly imported

class FoodDetailPage extends StatefulWidget {
  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  double spiciness = 0.0;
  int portion = 2;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> orderNow() async {
    try {
      await firestore.collection('order1').add({
        'food_name': 'Cheeseburger from Wendy\'s Burger',
        'spiciness': spiciness,
        'portion': portion,
        'price': 100,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );

      // Navigate to PaymentPage after order is placed
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentPage()),
      );
    } catch (error) {
      print("Failed to place order: $error"); // Debugging print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Cheeseburger from Wendy\'s Burger'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                'assets/jk.jpg', // Use a valid image URL
                height: 200,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Cheeseburger from Wendy's Burger",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange),
                Text('4.9'),
                SizedBox(width: 10),
                Text('26 mins'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "The Cheeseburger from Wendy's Burger is a classic fast food burger "
              "that packs a punch of flavor in every bite.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spiciness'),
                Expanded(
                  child: Slider(
                    value: spiciness,
                    min: 0,
                    max: 10,
                    onChanged: (value) {
                      setState(() {
                        spiciness = value;
                      });
                    },
                  ),
                ),
                Text(spiciness.toStringAsFixed(1)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Portion'),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (portion > 1) {
                          setState(() {
                            portion--;
                          });
                        }
                      },
                    ),
                    Text(portion.toString()),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          portion++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹100',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    orderNow(); // Call the order function
                  },
                  child: Text('ORDER NOW'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
