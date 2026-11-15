import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/organizer.dart';
import '../repositories/organizer_repository.dart';

class OrganizerProvider extends ChangeNotifier {
  final OrganizerRepository _repository = OrganizerRepository();
  final _uuid = const Uuid();

  List<Organizer> _organizers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Organizer> get organizers => List.unmodifiable(_organizers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrganizers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _organizers = await _repository.getOrganizers();
      // Sort alphabetically by name
      _organizers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      _errorMessage = 'Gagal memuat data penyelenggara: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new organizer with duplicate validation (case-insensitive & trimmed)
  Future<Organizer> addOrganizer(String rawName) async {
    final trimmedName = rawName.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Nama penyelenggara tidak boleh kosong');
    }

    // Check duplicate
    final existing = _organizers.where(
      (o) => o.name.toLowerCase() == trimmedName.toLowerCase(),
    );

    if (existing.isNotEmpty) {
      // Return existing organizer to avoid duplicates as requested in Section 5 & 17
      return existing.first;
    }

    final newOrganizer = Organizer(
      id: _uuid.v4(),
      name: trimmedName,
      createdAt: DateTime.now(),
    );

    _organizers.add(newOrganizer);
    _organizers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    await _repository.saveOrganizers(_organizers);
    notifyListeners();
    return newOrganizer;
  }

  // Update organizer name
  Future<void> updateOrganizer(String id, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Nama penyelenggara tidak boleh kosong');
    }

    final duplicate = _organizers.any(
      (o) => o.id != id && o.name.toLowerCase() == trimmedName.toLowerCase(),
    );
    if (duplicate) {
      throw Exception('Penyelenggara dengan nama "$trimmedName" sudah ada');
    }

    final index = _organizers.indexWhere((o) => o.id == id);
    if (index != -1) {
      _organizers[index] = _organizers[index].copyWith(name: trimmedName);
      _organizers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      await _repository.saveOrganizers(_organizers);
      notifyListeners();
    }
  }

  // Delete organizer
  Future<void> deleteOrganizer(String id) async {
    _organizers.removeWhere((o) => o.id == id);
    await _repository.saveOrganizers(_organizers);
    notifyListeners();
  }

  Organizer? getOrganizerById(String id) {
    try {
      return _organizers.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  String getOrganizerName(String id) {
    final org = getOrganizerById(id);
    return org?.name ?? 'Tidak diketahui';
  }
}
