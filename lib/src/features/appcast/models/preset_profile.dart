enum PresetProfile {
  sparkle2(
    label: 'Sparkle 2 (macOS Standard)',
    description: 'Modern standard with Ed25519 signatures, phased rollout, and multi-architecture enclosures.',
  ),
  flutterUpgrader(
    label: 'Flutter Upgrader',
    description: 'Enclosure-centric format tailored for pub.dev/packages/upgrader on Flutter Desktop & Web.',
  ),
  winSparkle(
    label: 'WinSparkle / NetSparkle',
    description: 'Windows and .NET application feed format supporting MSI, EXE, and Inno Setup installers.',
  );

  final String label;
  final String description;

  const PresetProfile({
    required this.label,
    required this.description,
  });
}
