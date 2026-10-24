import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appcast_generator/src/features/appcast/bloc/appcast_bloc.dart';
import 'package:appcast_generator/src/features/appcast/bloc/appcast_event.dart';
import 'package:appcast_generator/src/features/appcast/models/preset_profile.dart';
import 'package:appcast_generator/src/features/theme/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeCubit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial theme defaults to dark', () {
      final cubit = ThemeCubit();
      expect(cubit.state, ThemeMode.dark);
    });

    test('toggleTheme toggles between dark and light', () async {
      final cubit = ThemeCubit();
      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.light);
      await cubit.toggleTheme();
      expect(cubit.state, ThemeMode.dark);
    });
  });

  group('AppcastBloc Tests', () {
    late AppcastBloc bloc;

    setUp(() {
      bloc = AppcastBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('Initializes with default sample release and generated XML', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.items.length, 1);
      expect(bloc.state.generatedXml, contains('<rss version="2.0"'));
      expect(bloc.state.generatedXml, contains('<sparkle:version>1.0.0</sparkle:version>'));
    });

    test('ReleaseAdded adds new release to top of list', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const ReleaseAdded());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.items.length, 2);
      expect(bloc.state.items.first.version, '2.0.0');
    });

    test('PresetChanged switches preset and updates XML schema', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const PresetChanged(PresetProfile.flutterUpgrader));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.feed.preset, PresetProfile.flutterUpgrader);
      // In Flutter Upgrader, sparkle:version is on enclosure
      expect(bloc.state.generatedXml, contains('sparkle:version="1.0.0"'));
    });

    test('EnclosureAdded adds enclosure to release', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final releaseId = bloc.state.items.first.id;
      bloc.add(EnclosureAdded(releaseId));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final release = bloc.state.items.firstWhere((i) => i.id == releaseId);
      expect(release.enclosures.length, 3);
    });

    test('XmlImported parses and updates state', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      const testXml = '''<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Imported Feed</title>
    <link>https://imported.com</link>
    <item>
      <title>v9.9.9</title>
      <sparkle:version>9.9.9</sparkle:version>
      <pubDate>Fri, 20 Feb 2026 00:00:00 +0000</pubDate>
      <enclosure url="https://imported.com/app.zip" length="5000" type="application/zip"/>
    </item>
  </channel>
</rss>''';

      bloc.add(const XmlImported(testXml));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.feed.title, 'Imported Feed');
      expect(bloc.state.items.length, 1);
      expect(bloc.state.items.first.version, '9.9.9');
    });
  });
}
