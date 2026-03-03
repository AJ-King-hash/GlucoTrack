import 'package:flutter/material.dart';

abstract class LocaleState {
  const LocaleState();
}

class LocaleInitial extends LocaleState {
  const LocaleInitial();
}

class LocaleChanged extends LocaleState {
  final Locale locale;
  const LocaleChanged(this.locale);
}
