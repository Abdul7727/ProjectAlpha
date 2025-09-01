import 'package:flutter/material.dart';
import 'package:mystorage/themes/constants.dart';

class SubscriptionButton extends StatelessWidget {
  final String title;
  final VoidCallback action;

  SubscriptionButton({
    Key? key,
    required this.action,
    required this.title,
  }) : super(key: key);

  final Utils clr = Utils();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures the container takes up full width
      padding: const EdgeInsets.all(10), // Padding around the button
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffE21C34), Color(0xff500B28)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10), // Circular border radius
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.57), // Shadow for button
              blurRadius: 5, // Blur radius of shadow
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Make button's background transparent
            foregroundColor: Colors.transparent, // Make button's text color transparent
            shadowColor: Colors.transparent, // Remove shadow
            padding: EdgeInsets.zero, // Remove padding to ensure the gradient is visible
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Match the container's border radius
            ),
          ),
          onPressed: action,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0), // Adjust vertical padding as needed
            child: Text(
              title,
              style: TextStyle(
                color: clr.subsButtonText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
