import 'package:flutter_test/flutter_test.dart';
import 'package:libxd/collection.dart';

class TestItem {
  TestItem(this.optBool, this.optInt, this.optString);

  String optString;
  bool optBool;
  int optInt;
}

void main() {
  test('adding item to collection', () {
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

  test('adding item to collection updates item', () {
    final item = TestItem(true, 1, '111!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.set(item);

    item
      ..optInt = 42
      ..optBool = false;

    assert(collection.items.length == 1);
    assert(collection.get(item.optString)?.optBool == false);
    assert(collection.get(item.optString)?.optInt == 42);
  });

  test('adding multiple items to collection', () {
    final item = TestItem(true, 1, 'Libxd brah!');
    final item2 = TestItem(false, 2, 'Another one!!');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.setAll([item, item2]);
    assert(collection.items.length == 2);
  });

  test('adding multiple items to collection updates both items', () {
    final item = TestItem(true, 1, '111!');
    final item2 = TestItem(false, 2, '222');
    final collection = Collection<TestItem>(
      getModelId: (i) => i.optString,
    );
    collection.setAll([item, item2]);

    item
      ..optInt = 42
      ..optBool = false;
    item2
      ..optInt = 100
      ..optBool = true;

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
}
