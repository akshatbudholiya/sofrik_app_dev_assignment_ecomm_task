import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}