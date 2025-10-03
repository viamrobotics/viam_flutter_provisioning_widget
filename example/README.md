# Viam Flutter Bluetooth Provisioning Example

This directory contains a complete example app that demonstrates how to use the Viam Flutter Bluetooth Provisioning Widget with two flows: `BluetoothProvisioningFlow` and `BluetoothTetheringFlow`.

## Quick Start

1. **Update the constants** in `lib/consts.dart` with your Viam credentials:

```dart
class Consts {
  static const String apiKeyId = 'your-api-key-id';
  static const String apiKey = 'your-api-key';
  static const String organizationId = 'your-organization-id';

  static const String psk = 'viamsetup'; // if you specify a hotspot_password in viam-defaults.json this must be updated
}
```

2. **Run the app** on a physical device:

```bash
flutter run
```

## Requirements

- **Physical Device**: Must be run on a physical device (not a simulator)
- **viam-agent Version**: Machine must be running `0.20.0`+ for standard flow, `0.21.0`+ for tethering