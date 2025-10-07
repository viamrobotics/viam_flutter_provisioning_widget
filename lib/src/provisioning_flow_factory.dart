part of '../../viam_flutter_provisioning_widget.dart';

class ProvisioningFlowFactory {
  static Widget bluetoothProvisioningFlow({
    required Viam viam,
    required Robot robot,
    required RobotPart mainPart,
    required bool isNewMachine,
    required String psk,
    String? fragmentId,
    required String agentMinimumVersion,
    required bool tetheringEnabled,
    required BluetoothProvisioningFlowCopy bluetoothCopy,
    required VoidCallback onSuccess,
    required VoidCallback existingMachineExit,
    required VoidCallback nonexistentMachineExit,
    required VoidCallback agentMinimumVersionExit,
  }) {
    if (tetheringEnabled) {
      return BluetoothTetheringFlow(
        viam: viam,
        robot: robot,
        mainRobotPart: mainPart,
        isNewMachine: isNewMachine,
        psk: psk,
        fragmentId: fragmentId,
        agentMinimumVersion: agentMinimumVersion,
        copy: bluetoothCopy,
        onSuccess: onSuccess,
        existingMachineExit: existingMachineExit,
        nonexistentMachineExit: nonexistentMachineExit,
        agentMinimumVersionExit: agentMinimumVersionExit,
      );
    } else {
      return BluetoothProvisioningFlow(
        viam: viam,
        robot: robot,
        mainRobotPart: mainPart,
        isNewMachine: isNewMachine,
        psk: psk,
        fragmentId: fragmentId,
        agentMinimumVersion: agentMinimumVersion,
        copy: bluetoothCopy,
        onSuccess: onSuccess,
        existingMachineExit: existingMachineExit,
        nonexistentMachineExit: nonexistentMachineExit,
        agentMinimumVersionExit: agentMinimumVersionExit,
      );
    }
  }

  static Future<HotspotProvisioningResult?> hotspotProvisioningFlow({
    required BuildContext context,
    required Robot robot,
    required Viam viam,
    required RobotPart mainPart,
    required bool isNewMachine,
    required bool promptForCredentials,
    required bool replaceHardware,
    String? fragmentId,
    String? hotspotPrefix,
    String? hotspotPassword,
    Map<String, dynamic>? robotConfig,
  }) async {
    final result = await HotspotProvisioningFlow.show(
      context,
      robot: robot,
      viam: viam,
      mainPart: mainPart,
      fragmentId: fragmentId,
      hotspotPrefix: hotspotPrefix,
      hotspotPassword: hotspotPassword,
      promptForCredentials: promptForCredentials,
      isNewMachine: isNewMachine,
      replaceHardware: replaceHardware,
      robotConfig: robotConfig,
    );
    return result;
  }
}
