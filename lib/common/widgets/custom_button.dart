import 'package:flutter/material.dart';

import 'package:amazon_clone_app/constants/global_variables.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: color ?? GlobalVariables.secondaryColor,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, // Or Colors.white based on your design
        ),
      ),
    );
  }
}
