import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:feddan/app.dart';
import 'package:feddan/config/di/injection.dart';
import 'package:feddan/presentation/blocs/language/language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    setupDependencies();
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => getIt<LanguageBloc>(),
        child: const FeddanApp(),
      ),
    );
    expect(find.byType(FeddanApp), findsOneWidget);
  });
}
