import 'package:flutter/material.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Admin"),
      ),
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: GestureDetector(
          child: Card(
            elevation: 3,
            child: Container(
              height: 150,
              width: 150,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              color: Colors.orange.shade300,
              child: const Text(
                """
Reported
Comments""",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportScreen()),
            );
          },
        ),
      ),
    );
  }
}
