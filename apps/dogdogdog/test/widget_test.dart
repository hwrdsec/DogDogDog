import 'package:dogdogdog/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('host boots MaterialApp', (tester) async {
    await tester.pumpWidget(const DogDogDogApp());
    await tester.pump();
    expect(find.byType(DogDogDogApp), findsOneWidget);
  });
}
