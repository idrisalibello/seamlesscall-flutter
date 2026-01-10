import 'package:flutter/material.dart';

class ProviderOnboardingIntro extends StatelessWidget {
  const ProviderOnboardingIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Welcome to SeamlessCall Provider!',
      'Manage your jobs easily',
      'Track your earnings',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Onboarding')),
      body: PageView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    steps[index],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (index == steps.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Next phase (mock)')),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
