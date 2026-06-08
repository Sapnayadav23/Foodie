import 'package:flutter/material.dart';

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: const [
          Icon(Icons.wifi_off, size: 18, color: Colors.red),
          SizedBox(width: 8),
          Text('No internet connection',
              style: TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ),
    );
  }
}