import 'package:flutter/material.dart';

import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

import 'consts.dart';
import 'utils.dart';

class ProvisionNewRobotScreen extends StatefulWidget {
  const ProvisionNewRobotScreen({super.key});

  @override
  State<ProvisionNewRobotScreen> createState() => _ProvisionNewRobotScreenState();
}

class _ProvisionNewRobotScreenState extends State<ProvisionNewRobotScreen> {
  String? _robotName;
  bool _isLoadingStandardFlow = false;
  bool _isLoadingTetheringFlow = false;
  String? _errorString;

  Future<void> _createRobot({required bool tethering}) async {
    setState(() {
      if (tethering) {
        _isLoadingTetheringFlow = true;
      } else {
        _isLoadingStandardFlow = true;
      }
      _errorString = null;
    });
    try {
      final viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      final (robot, mainPart) = await Utils.createRobot(viam);
      setState(() {
        _robotName = robot.name;
      });
      await Future.delayed(const Duration(seconds: 3)); // delay is intentional, so you can see the robot name
      if (mounted) {
        if (tethering) {
          _goToBluetoothTetheringFlow(context, viam, robot, mainPart);
        } else {
          _goToBluetoothProvisioningFlow(context, viam, robot, mainPart);
        }
      }
    } catch (e) {
      debugPrint('Error creating robot: ${e.toString()}');
      setState(() {
        _errorString = e.toString();
      });
    } finally {
      setState(() {
        if (tethering) {
          _isLoadingTetheringFlow = false;
        } else {
          _isLoadingStandardFlow = false;
        }
        _robotName = null;
      });
    }
  }

  void _goToBluetoothProvisioningFlow(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BluetoothProvisioningFlow(
        viam: viam,
        robot: robot,
        isNewMachine: true,
        mainRobotPart: mainPart,
        psk: Consts.psk,
        fragmentId: null,
        agentMinimumVersion: '0.20.0',
        copy: BluetoothProvisioningFlowCopy(
          checkingOnlineSuccessSubtitle: '${robot.name} is connected and ready to use.',
        ),
        onSuccess: () {
          Navigator.of(context).pop();
        },
        existingMachineExit: () {
          Navigator.of(context).pop();
        },
        nonexistentMachineExit: () {
          Navigator.of(context).pop();
        },
        agentMinimumVersionExit: () {
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  void _goToBluetoothTetheringFlow(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BluetoothTetheringFlow(
        viam: viam,
        robot: robot,
        isNewMachine: true,
        mainRobotPart: mainPart,
        psk: Consts.psk,
        fragmentId: null,
        agentMinimumVersion: '0.20.0',
        copy: BluetoothProvisioningFlowCopy(
          checkingOnlineSuccessSubtitle: '${robot.name} is connected and ready to use.',
        ),
        onSuccess: () {
          Navigator.of(context).pop();
        },
        existingMachineExit: () {
          Navigator.of(context).pop();
        },
        nonexistentMachineExit: () {
          Navigator.of(context).pop();
        },
        agentMinimumVersionExit: () {
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Provisioning'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_robotName != null) Text('Provisioning machine named: $_robotName'),
            if (_robotName != null) const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () => (!_isLoadingTetheringFlow && !_isLoadingStandardFlow) ? _createRobot(tethering: false) : null,
                    child: _isLoadingStandardFlow
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
                          )
                        : const Text('Start Provisioning Flow'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: ValueKey('start-tethering'),
                    onPressed: () => (!_isLoadingTetheringFlow && !_isLoadingStandardFlow) ? _createRobot(tethering: true) : null,
                    child: _isLoadingTetheringFlow
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
                          )
                        : const Text('Start Tethering Flow'),
                  ),
                ],
              ),
            ),
            if (_errorString != null) const SizedBox(height: 16),
            if (_errorString != null) Text(_errorString!),
          ],
        ),
      ),
    );
  }
}
