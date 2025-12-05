// file: screens/web_stripe_checkout_screen_stub.dart

import 'package:flutter/material.dart';

class WebStripeCheckoutScreenStub extends StatelessWidget {
  final String amount;
  const WebStripeCheckoutScreenStub({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Web payments are not available on mobile."),
      ),
    );
  }
}
