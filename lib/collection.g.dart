// GENERATED CODE - DO NOT MODIFY BY HAND

part of libxd;

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Collection<T> on _Collection<T>, Store {
  late final _$_CollectionActionController =
      ActionController(name: '_Collection', context: context);

  @override
  T? get(String? id) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.get');
    try {
      return super.get(id);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  List<T?> getAll(Iterable<String?> ids) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.getAll');
    try {
      return super.getAll(ids);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  T set(T item) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.set');
    try {
      return super.set(item);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  T _set(T item, {bool withSort = true}) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection._set');
    try {
      return super._set(item, withSort: withSort);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  List<T> setAll(Iterable<T> models) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.setAll');
    try {
      return super.setAll(models);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  Collection<T> add(T model) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.add');
    try {
      return super.add(model);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  Collection<T> addAll(Iterable<T> models) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.addAll');
    try {
      return super.addAll(models);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  Collection<T> remove(T? model) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.remove');
    try {
      return super.remove(model);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  Collection<T> removeById(String? id) {
    final _$actionInfo = _$_CollectionActionController.startAction(
        name: '_Collection.removeById');
    try {
      return super.removeById(id);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  Collection<T> clear() {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.clear');
    try {
      return super.clear();
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  Collection<T> move(int fromIndex, int toIndex) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.move');
    try {
      return super.move(fromIndex, toIndex);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  List<T> filter(dynamic Function(T) variable, dynamic value) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.filter');
    try {
      return super.filter(variable, value);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sort(String Function(T) variable, String order) {
    final _$actionInfo =
        _$_CollectionActionController.startAction(name: '_Collection.sort');
    try {
      return super.sort(variable, order);
    } finally {
      _$_CollectionActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
