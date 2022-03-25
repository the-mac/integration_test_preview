import 'package:flutter/material.dart';

class HelloPage extends StatelessWidget {
  
  const HelloPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Hello, Flutter!',
        key: Key('hello-page-text'),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Color(0xff0085E0),
            fontSize: 48,
            fontWeight: FontWeight.bold
        )
      ),
    );
  }
}
