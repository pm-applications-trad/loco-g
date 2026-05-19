import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class HapticService {
  bool _enabled = true;

  bool get isEnabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void lightImpact() {
    if (_enabled && !kIsWeb) {
      HapticFeedback.lightImpact();
    }
  }

  void mediumImpact() {
    if (_enabled && !kIsWeb) {
      HapticFeedback.mediumImpact();
    }
  }

  void heavyImpact() {
    if (_enabled && !kIsWeb) {
      HapticFeedback.heavyImpact();
    }
  }

  void selectionClick() {
    if (_enabled && !kIsWeb) {
      HapticFeedback.selectionClick();
    }
  }

  void success() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_enabled && !kIsWeb) HapticFeedback.lightImpact();
    });
  }

  void error() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_enabled && !kIsWeb) HapticFeedback.heavyImpact();
    });
  }

  void reveal() {
    if (!_enabled || kIsWeb) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_enabled && !kIsWeb) HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      if (_enabled && !kIsWeb) HapticFeedback.mediumImpact();
    });
  }
}
