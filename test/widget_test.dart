import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_product_shelf/main.dart';
import 'package:my_product_shelf/providers/favourites_provider.dart';

void main() {
  testWidgets('App starts and shows My Shelf', (WidgetTester tester) async {
    // MyApp needs the Favourites provider above it, just like in main().
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Favourites(),
        child: const MyApp(),
      ),
    );

    expect(find.text('My Shelf'), findsOneWidget);
  });
}
