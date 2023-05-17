import 'package:flutter_test/flutter_test.dart';
import 'package:libxd/collection.dart';

class TestItem {
  TestItem(this.optBool, this.optInt, this.optString);

  String optString;
  bool optBool;
  int optInt;
}

void main() {
  test('setting item in collection adds item', () {
    final item = TestItem(true, 1, 'Libxd brah!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.set(item);
    assert(collection.items.length == 1);
    assert(collection.items.first.optBool == true);
    assert(collection.items.first.optInt == 1);
    assert(collection.items.first.optString == 'Libxd brah!');
  });

  test('setting item in collection updates item', () {
    final item = TestItem(true, 1, '111!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.set(item);

    final updatedItem = TestItem(false, 42, '111!');
    collection.set(updatedItem);

    assert(collection.items.length == 1);
    assert(collection.get(item.optString)?.optBool == false);
    assert(collection.get(item.optString)?.optInt == 42);
  });

  test('setting multiple items to collection', () {
    final item = TestItem(true, 1, 'Libxd brah!');
    final item2 = TestItem(false, 2, 'Another one!!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.setAll([item, item2]);
    assert(collection.items.length == 2);
  });

  test('setting multiple items to collection updates both items', () {
    final item = TestItem(true, 1, '111!');
    final item2 = TestItem(false, 2, '222');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.setAll([item, item2]);

    final updatedItem = TestItem(false, 42, '111!');
    final updatedItem2 = TestItem(true, 100, '222');
    collection.setAll([updatedItem, updatedItem2]);

    assert(collection.items.length == 2);
    assert(collection.get(item.optString)?.optBool == false);
    assert(collection.get(item.optString)?.optInt == 42);
    assert(collection.get(item2.optString)?.optBool == true);
    assert(collection.get(item2.optString)?.optInt == 100);
  });

  test('get item from collection', () {
    final item = TestItem(true, 1, 'Libxd brah!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.set(item);
    final result = collection.get(item.optString);
    assert(collection.items.length == 1);
    assert(result?.optBool == true);
    assert(result?.optInt == 1);
    assert(result?.optString == 'Libxd brah!');
  });

  test('remove item from collection by reference', () {
    final item = TestItem(true, 1, 'Libxd brah!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.set(item);
    assert(collection.items.length == 1);
    collection.remove(item);
    assert(collection.isEmpty);
  });

  test('remove item from collection by ID', () {
    final item = TestItem(true, 1, 'Libxd brah!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.set(item);
    assert(collection.items.length == 1);
    collection.removeById(item.optString);
    assert(collection.isEmpty);
  });

  test('adding item in collection adds item', () {
    final item = TestItem(false, 42, '111!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.add(item);

    assert(collection.items.length == 1);
    assert(collection.get(item.optString)?.optBool == false);
    assert(collection.get(item.optString)?.optInt == 42);
  });

  test('collection automatically sorts when adding items', () {
    final item = TestItem(true, 1, '111');
    final item2 = TestItem(true, 2, '222');
    final item3 = TestItem(true, 3, '333');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
      sortBy: CollectionSort((v) => v.optInt.toString(), 'desc'),
    );

    collection.addAll([item, item2]);
    assert(collection.items.first.optInt == 2);

    collection.add(item3);
    assert(collection.items.first.optInt == 3);
  });

  test('collection automatically sorts when setting items', () {
    final item = TestItem(true, 3, '111');
    final item2 = TestItem(true, 4, '222');
    final item3 = TestItem(true, 5, '333');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
      sortBy: CollectionSort((v) => v.optInt.toString(), 'desc'),
    );

    collection.setAll([item, item2]);
    assert(collection.items.first.optInt == 4);

    collection.set(item3);
    assert(collection.items.first.optInt == 5);

    // Let's update our item3 and ensure the colelction is sorted.
    final item4 = TestItem(true, 2, '333');
    collection.set(item4);
    assert(collection.items.first.optInt == 4);

    final item5 = TestItem(true, 9, '111');
    collection.set(item5);
    assert(collection.items.first.optInt == 9);
  });

  test('updating item emits event on items list', () {
    final item = TestItem(true, 3, '111');
    final item2 = TestItem(true, 4, '222');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
      sortBy: CollectionSort((v) => v.optInt.toString(), 'desc'),
    );

    collection.setAll([item, item2]);
    assert(collection.items.first.optInt == 4);

    var count = 0;
    collection.items.observe((p0) {
      count += 1;
    });

    // Let's update our item3 and ensure the colelction is sorted.
    final item5 = TestItem(true, 9, '111');
    collection.set(item5);
    assert(count >= 1);
  });

  test('updating item emits event on collection', () {
    final item = TestItem(true, 3, '111');
    final item2 = TestItem(true, 4, '222');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
      sortBy: CollectionSort((v) => v.optInt.toString(), 'desc'),
    );

    collection.setAll([item, item2]);
    assert(collection.items.first.optInt == 4);

    var count = 0;
    collection.observe((p0) {
      count += 1;
    });

    // Let's update our item3 and ensure the colelction is sorted.
    final item5 = TestItem(true, 9, '111');
    collection.set(item5);
    assert(count == 1);
  });

  test('updating multiple items emits single event on collection', () {
    final item = TestItem(true, 3, '111');
    final item2 = TestItem(true, 4, '222');
    final item3 = TestItem(true, 9, '333');
    final item4 = TestItem(true, 12, '444');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
      sortBy: CollectionSort((v) => v.optInt.toString(), 'desc'),
    );

    collection.set(item);

    var count = 0;
    collection.observe((p0) {
      count += 1;
    });

    collection.setAll([item2, item3, item4]);
    assert(count == 1);
  });

  test('setting multiple items emits single event on collection', () {
    final item = TestItem(true, 3, '111');
    final item2 = TestItem(true, 4, '222');
    final item3 = TestItem(true, 9, '333');
    final item4 = TestItem(true, 12, '444');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
      sortBy: CollectionSort((v) => v.optInt.toString(), 'desc'),
    );

    var count = 0;
    collection.observe((p0) {
      count += 1;
    });

    collection.setAll([item, item2, item3, item4]);
    assert(count == 1);
  });

  test('setting an item returns the updated item', () {
    final item = TestItem(true, 3, '111');
    final updatedItem = TestItem(false, 20, '111');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
      sortBy: CollectionSort((v) => v.optInt.toString(), 'desc'),
    );

    collection.set(item);
    final result = collection.set(updatedItem);

    assert(result.optBool == false);
    assert(result.optInt == 20);
  });
}
