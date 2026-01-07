import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ElderModeProvider extends ChangeNotifier {
  bool _isElderMode = false;
  final StorageService _storageService = StorageService();

  bool get isElderMode => _isElderMode;

  ElderModeProvider() {
    _loadElderMode();
  }

  Future<void> _loadElderMode() async {
    _isElderMode = await _storageService.getElderMode();
    notifyListeners();
  }

  Future<void> setElderMode(bool enabled) async {
    _isElderMode = enabled;
    await _storageService.saveElderMode(enabled);
    notifyListeners();
  }

  Future<void> toggleElderMode() async {
    await setElderMode(!_isElderMode);
  }
}
