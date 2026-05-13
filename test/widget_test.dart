import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:feddan/core/constants/app_constants.dart';
import 'package:feddan/presentation/blocs/language/language_bloc.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('feddan_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await Hive.openBox(AppConstants.settingsBox);
  });

  tearDown(() async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.clear();
    await box.close();
  });

  group('LanguageBloc', () {
    test('initial state defaults to Arabic', () {
      final bloc = LanguageBloc();
      expect(bloc.state.locale.languageCode, 'ar');
      bloc.close();
    });

    blocTest<LanguageBloc, LanguageState>(
      'emits English locale when LanguageChanged(en) is added',
      build: () => LanguageBloc(),
      act: (bloc) => bloc.add(const LanguageChanged(Locale('en'))),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<LanguageState>().having(
          (s) => s.locale.languageCode,
          'languageCode',
          'en',
        ),
      ],
    );

    blocTest<LanguageBloc, LanguageState>(
      'persists locale to Hive and restores on next instance',
      build: () => LanguageBloc(),
      act: (bloc) => bloc.add(const LanguageChanged(Locale('en'))),
      wait: const Duration(milliseconds: 100),
      verify: (_) {
        final box = Hive.box(AppConstants.settingsBox);
        expect(box.get(AppConstants.localeKey), 'en');
      },
    );

    test('restores persisted locale from Hive on init', () async {
      final box = Hive.box(AppConstants.settingsBox);
      await box.put(AppConstants.localeKey, 'en');

      final bloc = LanguageBloc();
      expect(bloc.state.locale.languageCode, 'en');
      bloc.close();
    });
  });
}
