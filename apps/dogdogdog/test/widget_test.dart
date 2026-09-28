import 'package:dogdogdog/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('host boots MaterialApp', (tester) async {
    await tester.pumpWidget(const DogDogDogApp());
    expect(find.byType(DogDogDogApp), findsOneWidget);
  });
}
