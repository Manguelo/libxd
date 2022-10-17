// ignore_for_file: invariant_booleans, library_private_types_in_public_api
library libxd;

import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';

part 'collection.g.dart';

class CollectionSort<T> {
  CollectionSort(this.variable, this.order);
  String Function(T) variable;
  String order;
}

class Collection<T> = _Collection<T> with _$Collection;

abstract class _Collection<T> with Store {
  _Collection({
    this.getModelId,
    this.update,
    this.create,
    this.sortBy,
  }) {
    getModelId ??= (dynamic s) => s?.id;
    update ??= (existing, data) {
      final indexToUpdate = items.indexOf(existing);
      if (indexToUpdate != -1) {
        items[indexToUpdate] = data;
      }
    };
    create ??= (input) => input;
  }

  /// Determines which variable on the model should be used for the ID.
  String? Function(T)? getModelId;

  /// A callback to update the model when creating a new instance in the collection.
  Function(T, T)? update;

  /// A callback to modify the model when creating a new instance in the collection.
  Function(T)? create;

  /// If provided, automatically sorts the colleciton after any addition.
  CollectionSort<T>? sortBy;

  /// All items within the collection.
  ObservableList<T> items = ObservableList<T>();
  Map<String, T> idMap = {};

  /// The count of all items in the collection.
  int get length {
    return items.length;
  }

  /// If the collection is NOT empty.
  bool get isNotEmpty {
    return items.isNotEmpty;
  }

  /// If the collection is empty.
  bool get isEmpty {
    return items.isEmpty;
  }

  /// Gets an item by it's ID.
  @action
  T? get(String? id) {
    if (id == null) {
      return null;
    }

    final idAsString = id.toString();
    final fromMap = idMap[idMap];
    if (fromMap != null) {
      return fromMap;
    }

    final found = items.firstWhereOrNull((item) {
      final modelId = getModelId!(item);
      if (modelId == null) {
        return false;
      }

      return modelId.toString() == idAsString;
    });

    if (found != null) {
      idMap.addAll({idAsString: found});
    }

    return found;
  }

  /// Get multiple items by their ID.
  @action
  List<T?> getAll(Iterable<String?> ids) {
    if (ids.isEmpty) {
      return [];
    }

    return ids.map((id) => get(id)).toList();
  }

  /// Given an object, intelligently adds or updates items.
  /// If an item representing the given input exists in the collection (based on getDataId),
  /// the update is called. If not, the create function is called and the result is added to the internal items array.
  @action
  T set(T item) {
    return _set(item);
  }

  /// Internal set method to optionally update with sort.
  @action
  T _set(T item, {bool withSort = true}) {
    var dataId = getModelId!(item);
    if (dataId == null) {
      throw FormatException('$dataId is not a valid id');
    }

    dataId = dataId.toString();

    var existing = get(dataId);
    if (existing != null) {
      update!(existing, item);
      _trySort(withSort);
      return existing;
    }

    final created = create!(item);

    // If creating this object resulted in another object with the same ID being
    // added, reuse it instead of adding this new one.
    existing = get(dataId);
    if (existing != null) {
      update!(existing, item);
      _trySort(withSort);
      return existing;
    }

    items.add(created);
    idMap.addAll({dataId: created});

    _trySort(withSort);

    return created;
  }

  /// Given an array of objects, intelligently adds or updates items.
  /// If items representing the given inputs exists in the collection (based on getDataId),
  /// the update is called. If not, the create function is called and the result is added to the internal items array.
  @action
  List<T> setAll(Iterable<T> models) {
    if (models.isEmpty) {
      return [];
    }
    final result = models.map((item) => _set(item, withSort: false)).toList();
    if (sortBy != null) {
      sort(sortBy!.variable, sortBy!.order);
    }
    return result;
  }

  /// Adds one item to the end of collection (does not call create).
  /// No updating is done here, existing items (based on referential equality) are not added again.
  @action
  Collection<T> add(T model) {
    addAll([model]);
    return this as Collection<T>;
  }

  /// Adds multiple items to the end of collection (does not call create).
  /// No updating is done here, existing items (based on referential equality) are not added again.
  @action
  Collection<T> addAll(Iterable<T> models) {
    // Try filtering out existing items.
    models = models.where((m) => !items.contains(m));
    items.addAll(models);
    if (sortBy != null) {
      sort(sortBy!.variable, sortBy!.order);
    }
    return this as Collection<T>;
  }

  /// Removes an item based on the item itself.
  @action
  Collection<T> remove(T? model) {
    if (model == null) {
      return this as Collection<T>;
    }

    items.remove(model);

    final modelId = getModelId!(model);
    if (modelId != null) {
      idMap.remove(modelId);
    }

    return this as Collection<T>;
  }

  /// Removes an item based on it's ID.
  @action
  Collection<T> removeById(String? id) {
    final model = get(id);
    return remove(model);
  }

  /// Clears the internal items array.
  @action
  Collection<T> clear() {
    items.clear();
    idMap.clear();
    return this as Collection<T>;
  }

  /// Moves an item from one position to another, checking that
  /// the indexes given are within bounds.
  @action
  Collection<T> move(int fromIndex, int toIndex) {
    _moveItem(items, fromIndex, toIndex);
    return this as Collection<T>;
  }

  /// Returns collection items where [variable] from [T] equals [value]
  @action
  List<T> filter(Function(T) variable, dynamic value) {
    return items.where((item) => variable(item) == value).toList();
  }

  /// Sorts collection items by order `asc` or `desc` based on the provided `variable`
  @action
  void sort(String Function(T) variable, String order) {
    if (order == 'asc') {
      items.sort((x, y) => variable(x).compareTo(variable(y)));
    } else {
      items.sort((x, y) => variable(y).compareTo(variable(x)));
    }
  }

  /// Tries to sort the collection if possible/
  @action
  void _trySort([bool withSort = true]) {
    if (withSort && sortBy != null) {
      sort(sortBy!.variable, sortBy!.order);
    }
  }
}

/// Moves an item from one position to another, checking that
/// the indexes given are within bounds.
ObservableList<T> _moveItem<T>(
    ObservableList<T> target, int fromIndex, int toIndex) {
  _checkIndex(target, fromIndex);
  _checkIndex(target, toIndex);
  if (fromIndex == toIndex) {
    return target;
  }
  final oldItems = List<T>.from(target);
  var newItems = <T>[];

  if (fromIndex < toIndex) {
    newItems = [
      ...oldItems.slice(0, fromIndex),
      ...oldItems.slice(fromIndex + 1, toIndex + 1),
      oldItems[fromIndex],
      ...oldItems.slice(toIndex + 1, oldItems.length),
    ];
  } else {
    // toIndex < fromIndex
    newItems = [
      ...oldItems.slice(0, toIndex),
      oldItems[fromIndex],
      ...oldItems.slice(toIndex, fromIndex),
      ...oldItems.slice(fromIndex + 1),
    ];
  }
  target.replaceRange(0, target.length, newItems);
  return target;
}

/// Checks whether the specified index is within bounds. Throws if not.
void _checkIndex(ObservableList<dynamic> target, num index) {
  if (index < 0) {
    throw FormatException(
        '[mobx.array] Index out of bounds: $index is negative');
  }
  final length = target.length;
  if (index >= length) {
    throw FormatException(
        '[mobx.array] Index out of bounds: $index is not smaller than $length');
  }
}
