import 'package:flutter_test/flutter_test.dart';

import 'package:shein/features/catalog/viewmodel/catalog_filter.dart';
import 'package:shein/data/models/product_model.dart';

import 'fixtures.dart';

List<ProductModel> catalog() => [
      productFixture(id: 'a', title: 'Blue Frock', group: 'women', price: 30, rating: 4.5, createdAtMs: 100),
      productFixture(id: 'b', title: 'Red Shirt', group: 'men', category: 'mens-shirts', categoryLabel: 'Shirts', price: 15, rating: 3.9, createdAtMs: 300, discount: 0),
      productFixture(id: 'c', title: 'Lipstick', group: 'beauty', category: 'beauty', categoryLabel: 'Makeup', price: 9, rating: 4.9, createdAtMs: 200, discount: 0),
      productFixture(id: 'd', title: 'Gold Watch', group: 'accessories', category: 'womens-watches', categoryLabel: 'Watches', price: 90, rating: 4.0, createdAtMs: 400, discount: 0),
      productFixture(id: 'e', title: 'Black Sunglasses', group: 'accessories', price: 50, rating: 4.2, createdAtMs: 500, discount: 50),
    ];

void main() {
  group('CatalogFilter.apply', () {
    test('group filter keeps matching group only', () {
      final result = CatalogFilter.apply(products: catalog(), group: 'women', query: '');
      expect(result.map((p) => p.id), ['a']);
    });

    test('pseudo groups: all keeps everything, sale keeps discounted only', () {
      final all = CatalogFilter.apply(products: catalog(), group: 'all', query: '');
      expect(all.length, 5);

      final sale = CatalogFilter.apply(products: catalog(), group: 'sale', query: '');
      expect(sale.map((p) => p.id).toSet(), {'a', 'e'});
    });

    test('search is case-insensitive on title', () {
      final result = CatalogFilter.apply(products: catalog(), group: 'all', query: '  blUe ');
      expect(result.map((p) => p.id), ['a']);
    });

    test('category label filter', () {
      final result = CatalogFilter.apply(
        products: catalog(),
        group: 'all',
        query: '',
        categoryLabel: 'Makeup',
      );
      expect(result.map((p) => p.id), ['c']);
    });

    test('price sorting asc/desc', () {
      final asc = CatalogFilter.apply(
        products: catalog(),
        group: 'all',
        query: '',
        sort: CatalogSort.priceAsc,
      );
      expect(asc.map((p) => p.price), [9, 15, 30, 50, 90]);

      final desc = CatalogFilter.apply(
        products: catalog(),
        group: 'all',
        query: '',
        sort: CatalogSort.priceDesc,
      );
      expect(desc.first.id, 'd');
    });

    test('newest sorting is createdAtMs desc', () {
      final result = CatalogFilter.apply(
        products: catalog(),
        group: 'all',
        query: '',
        sort: CatalogSort.newest,
      );
      expect(result.map((p) => p.id), ['e', 'd', 'b', 'c', 'a']);
    });

    test('rating sorting', () {
      final result = CatalogFilter.apply(
        products: catalog(),
        group: 'all',
        query: '',
        sort: CatalogSort.rating,
      );
      expect(result.first.id, 'c');
    });

    test('combines group + query + sort', () {
      final result = CatalogFilter.apply(
        products: catalog(),
        group: 'accessories',
        query: 'sun',
        sort: CatalogSort.priceDesc,
      );
      expect(result.map((p) => p.id), ['e']);
    });
  });

  group('CatalogFilter.categoryLabels', () {
    test('returns distinct labels in order, skipping empties', () {
      final labels = CatalogFilter.categoryLabels(catalog());
      expect(labels, ['Dresses', 'Shirts', 'Makeup', 'Watches']);
    });
  });

  group('CatalogFilter.titleFor', () {
    test('maps groups to titles', () {
      expect(CatalogFilter.titleFor('all'), 'All Products');
      expect(CatalogFilter.titleFor('new'), 'New In');
      expect(CatalogFilter.titleFor('sale'), 'Sale');
      expect(CatalogFilter.titleFor('women'), 'Women');
      expect(CatalogFilter.titleFor('unknown'), 'Shop');
    });
  });
}
