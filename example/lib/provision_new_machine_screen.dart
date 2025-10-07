import 'package:flutter/material.dart';

import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

import 'consts.dart';
import 'utils.dart';

enum ProvisioningFlow {
  standard,
  tethering,
  hotspot,
}

class ProvisionNewRobotScreen extends StatefulWidget {
  const ProvisionNewRobotScreen({super.key});

  @override
  State<ProvisionNewRobotScreen> createState() => _ProvisionNewRobotScreenState();
}

class _ProvisionNewRobotScreenState extends State<ProvisionNewRobotScreen> {
  String? _robotName;
  ProvisioningFlow? _isLoadingProvisioningFlow;
  String? _errorString;

  Future<void> _createRobot({required ProvisioningFlow provisioningFlow}) async {
    setState(() {
      switch (provisioningFlow) {
        case ProvisioningFlow.standard:
          _isLoadingProvisioningFlow = ProvisioningFlow.standard;
        case ProvisioningFlow.tethering:
          _isLoadingProvisioningFlow = ProvisioningFlow.tethering;
        case ProvisioningFlow.hotspot:
          _isLoadingProvisioningFlow = ProvisioningFlow.hotspot;
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
        switch (provisioningFlow) {
          case ProvisioningFlow.standard:
            _goToBluetoothProvisioningFlow(context, viam, robot, mainPart);
          case ProvisioningFlow.tethering:
            _goToBluetoothTetheringFlow(context, viam, robot, mainPart);
          case ProvisioningFlow.hotspot:
            _goToHotspotFlow(context, viam, robot, mainPart);
        }
      }
    } catch (e) {
      debugPrint('Error creating robot: ${e.toString()}');
      setState(() {
        _errorString = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingProvisioningFlow = null;
        _robotName = null;
      });
    }
  }

  void _goToBluetoothProvisioningFlow(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) {
    final widget = ProvisioningFlowFactory.bluetoothProvisioningFlow(
      viam: viam,
      robot: robot,
      isNewMachine: true,
      mainPart: mainPart,
      psk: Consts.psk,
      agentMinimumVersion: '0.20.0',
      tetheringEnabled: false,
      bluetoothCopy: BluetoothProvisioningFlowCopy(
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
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }

  void _goToBluetoothTetheringFlow(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) {
    final widget = ProvisioningFlowFactory.bluetoothProvisioningFlow(
      viam: viam,
      robot: robot,
      isNewMachine: true,
      mainPart: mainPart,
      psk: Consts.psk,
      agentMinimumVersion: '0.20.0',
      tetheringEnabled: true,
      bluetoothCopy: BluetoothProvisioningFlowCopy(
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
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }

  void _goToHotspotFlow(BuildContext context, Viam viam, Robot robot, RobotPart mainPart) async {
    final result = await ProvisioningFlowFactory.hotspotProvisioningFlow(
      context: context,
      viam: viam,
      robot: robot,
      isNewMachine: true,
      mainPart: mainPart,
      promptForCredentials: true,
      replaceHardware: false,
    );
    if (context.mounted) {
      switch (result?.status) {
        case RobotStatus.online:
          Navigator.of(context).pop();
        case RobotStatus.offline:
          Navigator.of(context).pop();
        case RobotStatus.loading:
          Navigator.of(context).pop();
        case null:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viam Provisioning'),
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
                    onPressed: () =>
                        (_isLoadingProvisioningFlow == null) ? _createRobot(provisioningFlow: ProvisioningFlow.standard) : null,
                    child: _isLoadingProvisioningFlow == ProvisioningFlow.standard
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
                    onPressed: () =>
                        (_isLoadingProvisioningFlow == null) ? _createRobot(provisioningFlow: ProvisioningFlow.tethering) : null,
                    child: _isLoadingProvisioningFlow == ProvisioningFlow.tethering
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
                          )
                        : const Text('Start Tethering Flow'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: ValueKey('start-hotspot'),
                    onPressed: () => (_isLoadingProvisioningFlow == null) ? _createRobot(provisioningFlow: ProvisioningFlow.hotspot) : null,
                    child: _isLoadingProvisioningFlow == ProvisioningFlow.hotspot
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(backgroundColor: Colors.white),
                          )
                        : const Text('Start Hotspot Flow'),
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
