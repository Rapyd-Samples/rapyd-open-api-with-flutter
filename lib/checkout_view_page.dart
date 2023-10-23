import 'package:flutter/material.dart';
import 'product.dart'; // Import the Product class
import 'utilities/rapyd.dart'; // Import the Rapyd Utilities

class CheckoutViewPage extends StatefulWidget {
  @override
  CheckoutViewPageState createState() => CheckoutViewPageState();
}

class CheckoutViewPageState extends State<CheckoutViewPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields controllers
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expMonthController = TextEditingController();
  final TextEditingController _expYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _handleSubmit() async {

    if (_formKey.currentState!.validate()) {
      // All fields are valid, proceed with payment
      String number = _numberController.text;
      String expMonth = _expMonthController.text;
      String expYear = _expYearController.text;
      String cvv = _cvvController.text;
      String name = _nameController.text;
      String email = _emailController.text;
      final Product product = ModalRoute.of(context)?.settings.arguments as Product;

      final rapydClient = Rapyd();
      final amount = product.price.toStringAsFixed(2);

      final body = <String, dynamic>{
        "amount": amount,
        "currency": "USD",
        "description": "Payment for ${product.name}",
        "receipt_email": email,
        "payment_method": {
              "type": "il_visa_card",
              "fields": {
                  "number": number,
                  "expiration_month": expMonth,
                  "expiration_year": expYear,
                  "cvv": cvv,
                  "name": name
              }
          }
      };

      try {
          final response = await rapydClient.makeRequest("post", "/v1/payments", body);

          if (response["paid"] == true) {

            redirectTo('/success');

          } else {

            redirectTo('/failed');

          }

          print (response);
        } catch (e) {
          print('ERROR: ${e.toString()}');
        }


    }
  }

  void redirectTo(String url) {
      Navigator.pushNamed(
        context,
        url
      );
  }

  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)?.settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase ${product.name}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid card number';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expMonthController,
                      decoration: InputDecoration(labelText: 'Expiration Month'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid expiration month';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _expYearController,
                      decoration: InputDecoration(labelText: 'Expiration Year'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid expiration year';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid CVV';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text('Pay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
