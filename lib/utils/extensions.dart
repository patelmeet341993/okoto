import 'package:flutter/material.dart';

extension EmptyCheckOnStringNullable on String? {
  bool get checkNotEmpty => (this ?? '').isNotEmpty;

  bool get checkEmpty => (this ?? '').isEmpty;
}

extension EmptyCheckOnMapNullable on Map? {
  bool get checkNotEmpty => (this ?? {}).isNotEmpty;

  bool get checkEmpty => (this ?? {}).isEmpty;
}

extension EmptyCheckOnListNullable on List? {
  bool get checkNotEmpty => (this ?? []).isNotEmpty;

  bool get checkEmpty => (this ?? []).isEmpty;
}

extension FirstOrLastElementInList<T> on List<T>? {
  T? get firstElement => checkNotEmpty ? this!.first : null;

  T? get lastElement => checkNotEmpty ? this!.last : null;
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}