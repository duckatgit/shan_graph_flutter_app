import 'package:flutter/material.dart';

extension DoubleExtension on double? {
  /// validate given int is not null and returns given value if null.
  double validate({double value = 0}) {
    return this ?? value;
  }

  /// Leaves given height of space
  Widget get height => SizedBox(height: this?.toDouble());

  /// Leaves given width of space
  Widget get width => SizedBox(width: this?.toDouble());
}
