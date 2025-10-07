import 'dart:async';

import 'package:flutter/material.dart';

import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

import 'consts.dart';

enum _RobotStatus { online, offline, awaitingSetup, loading }

class _ListRobot {
  final Robot robot;
  final String locationName;

  _ListRobot({required this.robot, required this.locationName});
}

class ReconnectRobotsScreen extends StatefulWidget {
  const ReconnectRobotsScreen({super.key});

  @override
  State<ReconnectRobotsScreen> createState() => _ReconnectRobotsScreenState();
}

class _ReconnectRobotsScreenState extends State<ReconnectRobotsScreen> {
  Viam? _viam;
  bool _isLoading = false;
  List<_ListRobot> _robots = [];
  final Map<String, _RobotStatus> _robotStatuses = {};
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _loadRobots();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRobots() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
      final locations = await _viam!.appClient.listLocations(Consts.organizationId);
      final newList = <_ListRobot>[];
      for (final location in locations) {
        final locationRobots = await _viam!.appClient.listRobots(location.id);
        newList.addAll(locationRobots.map((e) => _ListRobot(robot: e, locationName: location.name)));
      }
      for (final robot in newList) {
        _robotStatuses[robot.robot.id] = robot.robot.status;
      }
      setState(() {
        _robots = newList;
      });
      _startStatusTimer();
    } catch (e) {
      debugPrint('Error loading robots: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startStatusTimer() async {
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateRobotStatuses();
    });
  }

  Future<void> _updateRobotStatuses() async {
    debugPrint('Updating robot statuses');
    try {
      final statusFutures = _robots.map((robot) async {
        try {
          final reloadRobot = await _viam!.appClient.getRobot(robot.robot.id);
          final newStatus = reloadRobot.status;
          if (newStatus != _robotStatuses[reloadRobot.id]) {
            debugPrint('New status for robot ${reloadRobot.name} from ${_robotStatuses[reloadRobot.id]} to $newStatus');
            setState(() {
              _robotStatuses[reloadRobot.id] = newStatus;
            });
          }
        } catch (e) {
          debugPrint('Error getting status for robot ${robot.robot.id}: $e');
        }
      });
      await Future.wait(statusFutures);
      debugPrint('Robot statuses updated');
    } catch (e) {
      debugPrint('Error updating robot statuses: $e');
    }
  }

  void _goToBluetoothProvisioningFlow(BuildContext context, Viam viam, Robot robot) async {
    final mainPart = (await viam.appClient.listRobotParts(robot.id)).firstWhere((element) => element.mainPart);
    if (context.mounted) {
      final widget = ProvisioningFlowFactory.bluetoothProvisioningFlow(
        viam: viam,
        robot: robot,
        isNewMachine: false,
        mainPart: mainPart,
        psk: Consts.bluetoothPSK,
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
  }

  void _goToBluetoothTetheringFlow(BuildContext context, Viam viam, Robot robot) async {
    final mainPart = (await viam.appClient.listRobotParts(robot.id)).firstWhere((element) => element.mainPart);
    if (context.mounted) {
      final widget = ProvisioningFlowFactory.bluetoothProvisioningFlow(
        viam: viam,
        robot: robot,
        isNewMachine: false,
        mainPart: mainPart,
        psk: Consts.bluetoothPSK,
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
  }

  void _goToHotspotFlow(BuildContext context, Viam viam, Robot robot) async {
    final mainPart = (await viam.appClient.listRobotParts(robot.id)).firstWhere((element) => element.mainPart);
    if (context.mounted) {
      final result = await ProvisioningFlowFactory.hotspotProvisioningFlow(
        context: context,
        viam: viam,
        robot: robot,
        overrideFragment: false, // not needed on reconnect
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
  }

  void _showActionDialog(BuildContext context, Robot robot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(robot.name),
          content: const Text('How would you like to re-connect this machine?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goToBluetoothTetheringFlow(context, _viam!, robot);
              },
              child: const Text('Bluetooth Tethering'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goToBluetoothProvisioningFlow(context, _viam!, robot);
              },
              child: const Text('Bluetooth over WiFi'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goToHotspotFlow(context, _viam!, robot);
              },
              child: const Text('Hotspot'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconnect Machines'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive(backgroundColor: Colors.black))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _robots.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_robots[index].robot.name),
                subtitle: Text('location: ${_robots[index].locationName}'),
                trailing: _robotStatuses[_robots[index].robot.id]?.statusIcon,
                onTap: () => _showActionDialog(context, _robots[index].robot),
              ),
            ),
    );
  }
}

extension _RobotStatusCalculation on Robot {
  _RobotStatus get status {
    final seconds = lastAccess.seconds.toInt();
    final actual = DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;
    if ((actual - seconds) < 60) {
      return _RobotStatus.online;
    }

    if (!lastAccess.hasNanos() && !lastAccess.hasSeconds()) return _RobotStatus.awaitingSetup;
    if ((actual - seconds) > 60) return _RobotStatus.offline;
    return _RobotStatus.loading;
  }
}

extension _RobotStatusIcon on _RobotStatus {
  Icon get statusIcon {
    switch (this) {
      case _RobotStatus.online:
        return const Icon(Icons.check_circle, color: Colors.green);
      case _RobotStatus.offline:
        return const Icon(Icons.offline_bolt, color: Colors.grey);
      case _RobotStatus.awaitingSetup:
        return const Icon(Icons.snooze, color: Colors.blue);
      case _RobotStatus.loading:
        return const Icon(Icons.hourglass_empty, color: Colors.black);
    }
  }
}
