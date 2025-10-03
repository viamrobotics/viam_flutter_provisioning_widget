import 'package:flutter/material.dart';

import 'reconnect_machines_screen.dart';
import 'provision_new_machine_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _goToNewMachineFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ProvisionNewRobotScreen(),
    ));
  }

  void _goToReconnectMachinesFlow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ReconnectRobotsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              key: ValueKey('new-machine-flow'),
              onPressed: () => _goToNewMachineFlow(context),
              child: const Text('New Machine Flow'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: ValueKey('reconnect-flow'),
              onPressed: () => _goToReconnectMachinesFlow(context),
              child: const Text('Reconnect Machines'),
            ),
          ],
        ),
      ),
    );
  }
}
