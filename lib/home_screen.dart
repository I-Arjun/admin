import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Sdmin"),
      ),
      body: Center(
        child: GestureDetector(
          child: Container(
            child: const Text("Reports"),
          ),
          onTap: (){
            
          },
        ),
      ),
    );
  }
}
