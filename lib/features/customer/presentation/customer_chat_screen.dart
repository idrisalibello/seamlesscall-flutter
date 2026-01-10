import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';

class ChatShell extends StatelessWidget {
  const ChatShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Align(
              alignment: index % 2 == 0
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.blueAccent : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Message ${index + 1}',
                  style: TextStyle(
                    color: index % 2 == 0 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
