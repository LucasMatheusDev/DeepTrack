// empty widget default
import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  final String message;
  const NotFound({super.key, this.message = 'Not Found'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message),
    );
  }
}
