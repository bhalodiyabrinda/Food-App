import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductManager(),
    );
  }
}

class ProductManager extends StatefulWidget {
  @override
  _ProductManagerState createState() => _ProductManagerState();
}

class _ProductManagerState extends State<ProductManager> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  void _addOrUpdateProduct(String? docId) async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'productId': _idController.text,
        'name': _nameController.text,
        'code': _codeController.text,
        'price': double.parse(_priceController.text),
        'image': _imageController.text,
      };

      if (docId == null) {
        // Add new product
        await _products.add(data);
      } else {
        // Update product
        await _products.doc(docId).update(data);
      }

      // Clear form
      _idController.clear();
      _nameController.clear();
      _codeController.clear();
      _priceController.clear();
      _imageController.clear();

      Navigator.pop(context); // Close the dialog
    }
  }

  void _showForm([DocumentSnapshot? product]) {
    if (product != null) {
      _idController.text = product['productId'];
      _nameController.text = product['name'];
      _codeController.text = product['code'];
      _priceController.text = product['price'].toString();
      _imageController.text = product['image'];
    } else {
      _idController.clear();
      _nameController.clear();
      _codeController.clear();
      _priceController.clear();
      _imageController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Update Product'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(labelText: 'Product ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter product ID' : null,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter name' : null,
                  ),
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(labelText: 'Code'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter code' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter price' : null,
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter image URL' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _addOrUpdateProduct(product?.id),
              child: Text(product == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Manager'),
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products available.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((product) {
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    product['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image),
                  ),
                  title: Text(product['name']),
                  subtitle: Text('Code: ${product['code']}, Price: \$${product['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showForm(product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
