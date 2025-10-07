# Viam Flutter Provisioning Widget

This package provides a convenient way to import and use all available provisioning methods in your Flutter project.

This package currently wraps:
- [viam_flutter_bluetooth_provisioning](https://github.com/viamrobotics/viam_flutter_bluetooth_provisioning_widget)
- [viam_flutter_hotspot_provisioning](https://github.com/viamrobotics/viam_flutter_hotspot_provisioning_widget)

You can either use `ProvisioningFlowFactory` to generate a provisioning flow. Or use classes from the above packages directly. 

Reading the above package `README`s is required to get started and ensure your project is setup correctly. 

## Installation

```bash
flutter pub add viam_flutter_provisioning_widget
```

### Machine Setup

1. **Flash your Device**: See the [Viam Documentation](https://docs.viam.com/installation/prepare/rpi-setup) for device setup instructions (example with Raspberry Pi).

2. **Configure provisioning defaults**: Create a provisioning configuration file (`viam-defaults.json`):

   **For Bluetooth provisioning:**
   ```json
   {
     "network_configuration": {
       "disable_bt_provisioning": false
     }
   }
   ```

   **For Hotspot provisioning:**
   ```json
   {
     "network_configuration": {
       "hotspot_prefix": "your-hotspot-prefix",
       "disable_captive_portal_redirect": true,
       "hotspot_password": "your-hotspot-password",
       "fragment_id": "your-fragment-id"
     }
   }
   ```
   
   > **Note**: The `hotspot_prefix` must be at least 3 characters long. If you specify `hotspot_password` it will be used as a pre-shared key and should be passed into the provisioning flows.

   For more instructions, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#configure-defaults).

3. **Install viam-agent**: Run the pre-install script with your `viam-defaults.json`:
   ```bash
   sudo ./preinstall.sh
   ```
   
   For more instructions, see the [Viam Documentation](https://docs.viam.com/manage/fleet/provision/setup/#install-viam-agent).

### Device Requirements

- **Physical Device Required**: Apps must run on physical devices to discover nearby Bluetooth devices or connect to hotspots
- **Bluetooth Enabled**: For Bluetooth flows, ensure Bluetooth is enabled on both the mobile device and target machine
- **viam-agent Version**: 
  - Bluetooth standard flow requires `0.20.0`+
  - Bluetooth tethering requires `0.21.0`+

## Platform Requirements

### iOS

#### For Bluetooth Provisioning

Add to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Finding and connecting nearby local bluetooth devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Finding and connecting nearby local bluetooth devices</string>
```

#### For Hotspot Provisioning

Add to your `Entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.HotspotConfiguration</key>
    <true/>
    <key>com.apple.developer.networking.wifi-info</key>
    <true/>
</dict>
</plist>
```

### Android

Add to your `AndroidManifest.xml`:

#### For Bluetooth Provisioning

```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<!-- Location permissions required for Bluetooth scanning on Android 12+ -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### For Hotspot Provisioning

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
<uses-permission android:name="android.permission.WRITE_SETTINGS"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

## Usage

### Viam Setup

Before starting any provisioning flow, you need to:

1. Create a [Viam](https://flutter.viam.dev/viam_sdk/Viam-class.html) instance
2. Either create a new robot or retrieve an existing one
3. Retrieve the main robot part

```dart
// Initialize Viam instance
final viam = await Viam.withApiKey(apiKeyId, apiKey);

// Get or create a robot
final robot = await viam.appClient.getRobot(robotId);
// OR create a new robot:
// final robotId = await viam.appClient.newMachine(robotName, locationId);
// final robot = await viam.appClient.getRobot(robotId);

// Get the main robot part
final mainPart = (await viam.appClient.listRobotParts(robot.id))
    .firstWhere((element) => element.mainPart);
```

### Using the Factory

The recommended way to create provisioning flows is through the `ProvisioningFlowFactory`:

#### Bluetooth Provisioning

```dart
import 'package:viam_flutter_provisioning_widget/viam_flutter_provisioning_widget.dart';

// Create a Bluetooth flow (standard or tethering based on tetheringEnabled)
final bluetoothFlow = ProvisioningFlowFactory.bluetoothProvisioningFlow(
  viam: viam,
  robot: robot,
  mainPart: mainPart,
  isNewMachine: true,
  psk: 'viamsetup', // Must match hotspot_password from viam-defaults.json
  fragmentId: null, // When null, fragment will be read from viam-defaults.json
  agentMinimumVersion: '0.21.0', // Use '0.20.0' for standard flow
  tetheringEnabled: true, // Set to false for standard provisioning
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

#### Hotspot Provisioning

```dart
// Option 1: Use hardcoded credentials
final result = await ProvisioningFlowFactory.hotspotProvisioningFlow(
  context: context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  isNewMachine: true,
  promptForCredentials: false,
  replaceHardware: false,
  fragmentId: 'your-fragment-id', // Optional
  hotspotPrefix: 'your-hotspot-prefix', // Must match viam-defaults.json
  hotspotPassword: 'your-hotspot-password', // Must match viam-defaults.json
);

// Option 2: Prompt user for credentials
final result = await ProvisioningFlowFactory.hotspotProvisioningFlow(
  context: context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  isNewMachine: true,
  promptForCredentials: true, // Shows credential input screen
  replaceHardware: false,
);

// Handle the result
if (result != null) {
  if (result.status == RobotStatus.online) {
    print('Robot ${result.robot.name} is online!');
  } else {
    print('Robot provisioning failed or timed out');
  }
}
```

### Direct Widget Usage (Alternative)

You can also use the widgets directly without the factory:

```dart
// Direct BluetoothProvisioningFlow usage
Navigator.of(context).push(MaterialPageRoute(
  builder: (context) => BluetoothProvisioningFlow(
    viam: viam,
    robot: robot,
    mainRobotPart: mainPart,
    isNewMachine: true,
    psk: 'viamsetup',
    fragmentId: null,
    agentMinimumVersion: '0.20.0',
    copy: BluetoothProvisioningFlowCopy(),
    onSuccess: () => Navigator.of(context).pop(),
    existingMachineExit: () => Navigator.of(context).pop(),
    nonexistentMachineExit: () => Navigator.of(context).pop(),
    agentMinimumVersionExit: () => Navigator.of(context).pop(),
  ),
));

// Direct HotspotProvisioningFlow usage
final result = await HotspotProvisioningFlow.show(
  context,
  robot: robot,
  viam: viam,
  mainPart: mainPart,
  hotspotPrefix: 'your-prefix',
  hotspotPassword: 'your-password',
  promptForCredentials: false,
  isNewMachine: true,
);
```

## Flow Details

### BluetoothProvisioningFlow
- Scans for nearby Viam machines via Bluetooth
- Connects to selected machine
- Configures Wi-Fi credentials
- Verifies machine comes online
- **Requires**: viam-agent `0.20.0`+

### BluetoothTetheringFlow
- All features of BluetoothProvisioningFlow
- Adds internet tethering through mobile device
- Ideal for machines without direct network access
- **Requires**: viam-agent `0.21.0`+

### HotspotProvisioningFlow
- Connects to robot's hotspot
- Discovers available networks
- Configures network credentials
- Supports public networks (no password)
- Manual network entry fallback
- **Features**:
  - User-friendly error messages
  - Network type indicators (public/private)
  - Credential input options (hardcoded or user-prompted)

## Parameters

### Common Parameters

- `viam`: Viam SDK instance
- `robot`: The robot to provision
- `mainPart`: The main robot part
- `isNewMachine`: `true` for new machines, `false` for reconnecting
- `fragmentId`: Fragment ID to configure (optional, reads from viam-defaults.json if null)

### Bluetooth-Specific Parameters

- `psk`: Pre-shared key (must match `hotspot_password` from viam-defaults.json)
- `agentMinimumVersion`: Minimum required viam-agent version
- `tetheringEnabled`: Enable tethering flow vs standard flow
- `bluetoothCopy`: Custom copy/text for the flow
- `onSuccess`, `existingMachineExit`, `nonexistentMachineExit`, `agentMinimumVersionExit`: Callback functions

### Hotspot-Specific Parameters

- `hotspotPrefix`: Robot's hotspot SSID prefix (min 3 characters, must match viam-defaults.json)
- `hotspotPassword`: Hotspot password (must match viam-defaults.json)
- `promptForCredentials`: Show credential input screen vs use hardcoded values
- `replaceHardware`: Whether this is a hardware replacement
- `robotConfig`: Optional robot configuration

## Examples

For complete working examples, see the [example app](example/README.md).

## Important Notes

- **Do not connect manually**: Users should not connect to hotspots through device Wi-Fi settings
- **Credential matching**: Hotspot credentials must match `viam-defaults.json` configuration
- **Physical device**: Provisioning requires a physical device, not a simulator
- **Permissions**: Ensure all required platform permissions are configured

## Troubleshooting

### Bluetooth Issues
- **Cannot discover devices**: Ensure Bluetooth is enabled and permissions are granted
- **Connection fails**: Verify viam-agent version meets minimum requirements
- **PSK mismatch**: Ensure PSK matches `hotspot_password` in viam-defaults.json

### Hotspot Issues
- **Cannot connect to hotspot**: Verify hotspot prefix and password match viam-defaults.json
- **Permission errors**: Check iOS entitlements and Android permissions are configured
- **Robot not appearing**: Verify robot is flashed with Viam image and viam-defaults.json
- **Network not found**: Ensure robot's hotspot is active and broadcasting

## License

See the [LICENSE](LICENSE) file for license rights and limitations.
