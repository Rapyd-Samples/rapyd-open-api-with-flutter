import 'package:flutter/material.dart';
import 'payment_page.dart'; // Import the payment success/failure page
import 'product.dart'; // Import the Product class

class ProductViewPage extends StatelessWidget {
  final Product product;

  ProductViewPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product View'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(product.image, height: 200, width: 200),
            SizedBox(height: 20),
            Text(
              'Product Name: ${product.name}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'SKU: ${product.sku}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Description: ${product.description}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Price: \$${product.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                // Simulate payment success
                bool paymentSuccess = true;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage(status: paymentSuccess ? PaymentStatus.success : PaymentStatus.failure,)),
                );
                
              },
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
