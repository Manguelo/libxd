// ignore_for_file: invariant_booleans, library_private_types_in_public_api
library libxd;

import 'package:collection/collection.dart';
import 'package:mobx/mobx.dart';

class CollectionSort<T> {
  CollectionSort(this.variable, this.order);
  String Function(T) variable;
  String order;
}

class CollectionChange<T> {
  CollectionChange({required this.collection});

  final Collection<T> collection;
}

class Collection<T> implements Listenable<CollectionChange<T>> {
  Collection({
    this.getModelId,
    this.update,
    this.create,
    this.sortBy,
  }) {
    getModelId ??= (dynamic s) => s?.id;
    update ??= (existing, data) => _update(existing, data);
    create ??= (input) => input;
    _atom = Atom(
        name: mainContext.nameFor('ObservableList<$T>'), context: mainContext);
  }

  // Mobx stuff
  late Atom _atom;
  Listeners<CollectionChange<T>>? _listenersField;
  Listeners<CollectionChange<T>> get _listeners =>
      _listenersField ??= Listeners(mainContext);

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

  // Notify Mobx that a change has been made to our collection.
  void _notifyUpdate([bool isSingleUpdate = true]) {
    // Only fire an updated event if we are doing a single update action.
    // Otherwise, when calling setAll we'll get an event for each item updated.
    if (isSingleUpdate) {
      mainContext.conditionallyRunInAction(
        () => _notifyCollectionUpdate(),
        _atom,
      );
    }
  }

  /// Gets an item by it's ID.
  T? get(String? id) {
    _atom.reportObserved();
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
  List<T?> getAll(Iterable<String?> ids) {
    _atom.reportObserved();
    if (ids.isEmpty) {
      return [];
    }

    return ids.map((id) => get(id)).toList();
  }

  /// Given an object, intelligently adds or updates items.
  /// If an item representing the given input exists in the collection (based on getDataId),
  /// the update is called. If not, the create function is called and the result is added to the internal items array.

  T set(T item) {
    return _set(item);
  }

  /// Internal set method to optionally update with sort.
  T _set(T item, {bool isSingleUpdate = true}) {
    var dataId = getModelId!(item);
    if (dataId == null) {
      throw FormatException('$dataId is not a valid id');
    }

    dataId = dataId.toString();

    var existing = get(dataId);
    if (existing != null) {
      update!(existing, item);
      existing = get(dataId);
      _trySort(isSingleUpdate);
      _notifyUpdate(isSingleUpdate);
      return existing!;
    }

    final created = create!(item);

    // If creating this object resulted in another object with the same ID being
    // added, reuse it instead of adding this new one.
    existing = get(dataId);
    if (existing != null) {
      update!(existing, item);
      _trySort(isSingleUpdate);
      _notifyUpdate(isSingleUpdate);
      return existing;
    }

    items.add(created);
    idMap.addAll({dataId: created});
    _trySort(isSingleUpdate);
    _notifyUpdate(isSingleUpdate);

    return created;
  }

  /// Given an array of objects, intelligently adds or updates items.
  /// If items representing the given inputs exists in the collection (based on getDataId),
  /// the update is called. If not, the create function is called and the result is added to the internal items array.

  List<T> setAll(Iterable<T> models) {
    if (models.isEmpty) {
      return [];
    }
    final result =
        models.map((item) => _set(item, isSingleUpdate: false)).toList();
    if (sortBy != null) {
      sort(sortBy!.variable, sortBy!.order);
    }
    _notifyUpdate();
    return result;
  }

  /// Adds one item to the end of collection (does not call create).
  /// No updating is done here, existing items (based on referential equality) are not added again.
  Collection<T> add(T model) {
    addAll([model]);
    return this;
  }

  /// Adds multiple items to the end of collection (does not call create).
  /// No updating is done here, existing items (based on referential equality) are not added again.
  Collection<T> addAll(Iterable<T> models) {
    // Try filtering out existing items.
    models = models.where((m) => !items.contains(m));
    items.addAll(models);
    if (sortBy != null) {
      sort(sortBy!.variable, sortBy!.order);
    }
    _notifyUpdate();
    return this;
  }

  /// Removes an item based on the item itself.
  Collection<T> remove(T? model) {
    if (model == null) {
      return this;
    }

    items.remove(model);

    final modelId = getModelId!(model);
    if (modelId != null) {
      idMap.remove(modelId);
    }
    _notifyUpdate();
    return this;
  }

  /// Removes an item based on it's ID.
  Collection<T> removeById(String? id) {
    final model = get(id);
    return remove(model);
  }

  void _update(T existing, T data) {
    final indexToUpdate = items.indexOf(existing);
    if (indexToUpdate != -1) {
      items[indexToUpdate] = data;
    }
  }

  /// Clears the internal items array.
  Collection<T> clear() {
    items.clear();
    idMap.clear();
    _notifyUpdate();
    return this;
  }

  /// Moves an item from one position to another, checking that
  /// the indexes given are within bounds.
  Collection<T> move(int fromIndex, int toIndex) {
    _moveItem(items, fromIndex, toIndex);
    _notifyUpdate();
    return this;
  }

  /// Returns collection items where [variable] from [T] equals [value]
  List<T> filter(Function(T) variable, dynamic value) {
    return items.where((item) => variable(item) == value).toList();
  }

  /// Sorts collection items by order `asc` or `desc` based on the provided `variable`
  void sort(String Function(T) variable, String order) {
    if (order == 'asc') {
      items.sort((x, y) => variable(x).compareTo(variable(y)));
    } else {
      items.sort((x, y) => variable(y).compareTo(variable(x)));
    }
  }

  /// Tries to sort the collection if possible/
  void _trySort([bool withSort = true]) {
    if (withSort && sortBy != null) {
      sort(sortBy!.variable, sortBy!.order);
    }
  }

  ///
  /// MobX stuff to make this class observable
  ///
  void _notifyCollectionUpdate() {
    _atom.reportChanged();
    _listeners.notifyListeners(CollectionChange<T>(collection: this));
  }

  @override
  Dispose observe(Listener<CollectionChange<T>> listener,
      {bool fireImmediately = false}) {
    return _listeners.add(listener);
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
