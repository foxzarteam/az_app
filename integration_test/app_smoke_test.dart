import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;
import 'package:mobile/utils/constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and renders first frame safely', (tester) async {
    app.main();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);

    final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
    final hasLoader = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasAppName = find.text(AppConstants.appName).evaluate().isNotEmpty;

    expect(hasScaffold || hasLoader || hasAppName, isTrue);
  });
}
