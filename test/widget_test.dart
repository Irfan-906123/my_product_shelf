import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_product_shelf/main.dart';
import 'package:my_product_shelf/providers/favourites_provider.dart';
import 'package:my_product_shelf/providers/profile_provider.dart';
import 'package:my_product_shelf/services/storage_service.dart';

void main() {
  testWidgets('App starts and shows My Shelf', (WidgetTester tester) async {
    final storage = StorageService();

    // MyApp needs both providers above it, just like in main().
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Favourites(storage)),
          ChangeNotifierProvider(create: (_) => ProfileProvider(storage)),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('My Shelf'), findsOneWidget);
  });
}
