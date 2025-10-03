import 'dart:math';

import 'package:flutter/material.dart';
import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

import 'consts.dart';

class Utils {
  static Future<(Robot robot, RobotPart mainPart)> createRobot(Viam viam) async {
    final viam = await Viam.withApiKey(Consts.apiKeyId, Consts.apiKey);
    final location = await viam.appClient.createLocation(Consts.organizationId, 'test-location-${Random().nextInt(1000)}');
    final String robotName = "tester-${Random().nextInt(1000)}";
    final robotId = await viam.appClient.newMachine(robotName, location.id);
    debugPrint('created robot: $robotName, at location: ${location.name}');
    final robot = await viam.appClient.getRobot(robotId);
    final mainPart = (await viam.appClient.listRobotParts(robotId)).firstWhere((element) => element.mainPart);
    return (robot, mainPart);
  }
}
