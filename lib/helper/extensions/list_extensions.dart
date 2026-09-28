import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

extension IterableExt<T> on Iterable<T> {
  List<T> sortedList<S extends Comparable>([S Function(T)? keyOf]) => toList()
    ..sort(keyOf == null ? null : ((a, b) => keyOf(a).compareTo(keyOf(b))));

  List<S> mapIndexed<S>(S Function(int, T) func) => toList()
      .asMap()
      .map((index, value) => MapEntry(index, func(index, value)))
      .values
      .toList();

  List<T> get withoutNulls => where((s) => s != null).map((e) => e!).toList();

  List<T> unique(dynamic Function(T) getKey) {
    var distinctSet = <dynamic>{};
    var distinctList = <T>[];
    for (var item in this) {
      if (distinctSet.add(getKey(item))) {
        distinctList.add(item);
      }
    }
    return distinctList;
  }

  bool containsMap(dynamic map) => map is Map
      ? any((e) => e is Map && const DeepCollectionEquality().equals(e, map))
      : contains(map);
}

extension ListDivideExt<T extends Widget> on Iterable<T> {
  Iterable<MapEntry<int, Widget>> get enumerate => toList().asMap().entries;

  List<Widget> divide(Widget t, {bool Function(int)? filterFn}) => isEmpty
      ? []
      : enumerate
          .map((e) => [e.value, if (filterFn == null || filterFn(e.key)) t])
          .expand((i) => i)
          .toList()
        ..removeLast();

  List<Widget> addToStart(Widget t) => enumerate.map((e) => e.value).toList()..insert(0, t);

  List<Widget> addToEnd(Widget t) => enumerate.map((e) => e.value).toList()..add(t);

  List<Widget> addToIndex(Widget t, int index) => enumerate.map((e) => e.value).toList()..insert(index, t);
}

extension MapFilterExtensions<T> on Map<String, T?> {
  Map<String, T> get withoutNulls => Map.fromEntries(entries
      .where((e) => e.value != null)
      .map((e) => MapEntry(e.key, e.value as T)));
}