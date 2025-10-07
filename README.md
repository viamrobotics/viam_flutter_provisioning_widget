# Viam Flutter Provisioning Widget

This package provides a convenient way to import and use all available [viam-agent](https://docs.viam.com/manage/reference/viam-agent/) provisioning methods in your Flutter project.

This package currently wraps:
- [viam_flutter_bluetooth_provisioning_widget](https://github.com/viamrobotics/viam_flutter_bluetooth_provisioning_widget)
- [viam_flutter_hotspot_provisioning_widget](https://github.com/viamrobotics/viam_flutter_hotspot_provisioning_widget)

You can either use `ProvisioningFlowFactory` to generate a provisioning flow, or use the classes from the above packages directly. 

Reading the `README` for each package is required to ensure your project is setup correctly for the flows you want to support. 
- [Bluetooth Widget README](https://github.com/viamrobotics/viam_flutter_bluetooth_provisioning_widget/blob/main/README.md)
- [Hotspot Widget README](https://github.com/viamrobotics/viam_flutter_hotspot_provisioning_widget/blob/main/README.md)

## Installation

```bash
flutter pub add viam_flutter_provisioning_widget
```
## Usage

```dart
import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

// Create a Bluetooth flow (standard or tethering based on tetheringEnabled)
final bluetoothFlow = ProvisioningFlowFactory.bluetoothProvisioningFlow(
  viam: viam,
  robot: robot,
  mainPart: mainPart,
  isNewMachine: true,
  psk: 'viamsetup', // Must match hotspot_password from viam-defaults.json
  fragmentId: null,
  agentMinimumVersion: '0.21.0',
  tetheringEnabled: tetheringEnabled,
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

// Navigate to the flow
Navigator.of(context).push(MaterialPageRoute(
  builder: (context) => bluetoothFlow,
));
```

## Examples

For complete working examples, see the [example app](example/README.md).

## License

See the [LICENSE](LICENSE) file for license rights and limitations.
