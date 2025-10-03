class Consts {
  // TODO: Populate with your own api Keys.
  static const String apiKeyId = '';
  static const String apiKey = '';

  static const String organizationId = '';

  /// defaults to 'viamsetup', but if your viam-agent network configuration: https://docs.viam.com/manage/reference/viam-agent/#network_configuration
  /// has a value set for hotspot_password that will be used instead.
  /// this pre-shared key is prepended to bluetooth characteristic writes and decoded on the viam-agent side.
  static const String psk = 'viamsetup';
}
