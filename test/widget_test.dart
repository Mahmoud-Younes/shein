import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shein/core/widgets/price_text.dart';
import 'package:shein/core/widgets/product_card.dart';
import 'package:shein/core/widgets/rating_stars.dart';

import 'fixtures.dart';

/// Pumps a card inside a fixed-size cell, like the GridView gives it
/// (240-wide column, aspect 0.62 → ~387px tall).
Future<void> pumpCard(WidgetTester tester, ProductCard card) async {
  await tester.pumpWidget(MaterialApp(
    home: Center(
      child: SizedBox(width: 240, height: 390, child: card),
    ),
  ));
  await tester.pump();
}

void main() {
  group('PriceText', () {
    testWidgets('shows price, old price and discount badge', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PriceText(price: 29.99, oldPrice: 34.13, discount: 12),
      ));
      expect(find.text('\$29.99'), findsOneWidget);
      expect(find.text('\$34.13'), findsOneWidget);
      expect(find.text('-12%'), findsOneWidget);
    });

    testWidgets('omits old price and badge when there is no discount', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PriceText(price: 9.99, oldPrice: 5, discount: 0),
      ));
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('\$5.00'), findsNothing);
      expect(find.text('-0%'), findsNothing);
    });
  });

  group('RatingStars', () {
    testWidgets('renders 4.5 stars with value and count', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: RatingStars(rating: 4.5, ratingCount: 177),
      ));
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text(' (177)'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_half_rounded), findsOneWidget);
    });

    testWidgets('renders 0 stars as borders', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: RatingStars(rating: 0, ratingCount: null),
      ));
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(5));
      expect(find.text(' (0)'), findsNothing);
    });
  });

  group('ProductCard', () {
    testWidgets('renders title, price, rating, heart and add-to-bag', (tester) async {
      var bagTaps = 0;
      var heartTaps = 0;
      await pumpCard(
        tester,
        ProductCard(
          product: productFixture(),
          isWishlisted: false,
          onToggleWishlist: () => heartTaps++,
          onAddToBag: () => bagTaps++,
        ),
      );
      expect(find.text('Blue Frock'), findsOneWidget);
      expect(find.text('\$29.99'), findsOneWidget);
      expect(find.text('ADD TO BAG'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.tap(find.text('ADD TO BAG'));
      expect(bagTaps, 1);
      expect(heartTaps, 1);
    });

    testWidgets('sold-out products show a badge and a disabled button', (tester) async {
      await pumpCard(
        tester,
        ProductCard(
          product: productFixture(stock: 0),
          isWishlisted: true,
          onToggleWishlist: () {},
          onAddToBag: () {},
        ),
      );
      expect(find.text('SOLD OUT'), findsOneWidget);
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'ADD TO BAG'),
      );
      expect(button.onPressed, isNull);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('empty image list renders a placeholder (no network)', (tester) async {
      await pumpCard(
        tester,
        ProductCard(
          product: productFixture(),
          isWishlisted: false,
          onToggleWishlist: () {},
          onAddToBag: () {},
        ),
      );
      expect(find.byType(Image), findsNothing);
      expect(find.text('Blue Frock'), findsOneWidget);
    });
  });
}
