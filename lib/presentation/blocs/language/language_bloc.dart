import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc()
      : super(LanguageState(locale: _savedLocale())) {
    on<LanguageChanged>(_onLanguageChanged);
  }

  static Locale _savedLocale() {
    final box = Hive.box(AppConstants.settingsBox);
    final code = box.get(AppConstants.localeKey, defaultValue: AppConstants.defaultLocale) as String;
    return Locale(code);
  }

  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<LanguageState> emit,
  ) async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.localeKey, event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }
}
