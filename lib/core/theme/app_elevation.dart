import 'package:flutter/material.dart';

/// Elevation & Subtle Border Tokens for ConnectSoar
abstract class AppElevation {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  // Dark Mode subtle glow elevation
  static const List<BoxShadow> darkGlow = [
    BoxShadow(
      color: Color(0x336366F1),
      blurRadius: 12,
      spreadRadius: -2,
      offset: Offset(0, 4),
    ),
  ];
}
