import 'dart:io';
import 'package:flutter/material.dart';
import '../models/certificate.dart';
import '../repositories/certificate_repository.dart';
import '../services/storage_service.dart';
import 'organizer_provider.dart';

class CertificateProvider extends ChangeNotifier {
  final CertificateRepository _repository = CertificateRepository();

  List<Certificate> _certificates = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter & Search states
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedOrganizerId;
  int? _selectedYear;
  String _sortBy = 'newest'; // 'newest', 'oldest', 'a-z', 'z-a'

  // Getters
  List<Certificate> get certificates => List.unmodifiable(_certificates);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedOrganizerId => _selectedOrganizerId;
  int? get selectedYear => _selectedYear;
  String get sortBy => _sortBy;

  int get activeFiltersCount {
    int count = 0;
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) count++;
    if (_selectedOrganizerId != null && _selectedOrganizerId!.isNotEmpty) count++;
    if (_selectedYear != null) count++;
    return count;
  }

  // Load all certificates and seed if first launch
  Future<void> initializeData(OrganizerProvider organizerProvider) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isSeeded = await StorageService.isDataSeeded();
      if (!isSeeded) {
        await StorageService.seedInitialData();
      }

      await organizerProvider.loadOrganizers();
      _certificates = await _repository.getCertificates();
    } catch (e) {
      _errorMessage = 'Gagal menginisialisasi data sertifikat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reload data
  Future<void> loadCertificates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _certificates = await _repository.getCertificates();
    } catch (e) {
      _errorMessage = 'Gagal memuat sertifikat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter setters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedOrganizerId(String? organizerId) {
    _selectedOrganizerId = organizerId;
    notifyListeners();
  }

  void setSelectedYear(int? year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedOrganizerId = null;
    _selectedYear = null;
    _sortBy = 'newest';
    notifyListeners();
  }

  // Computed Filtered Certificates
  List<Certificate> getFilteredCertificates(OrganizerProvider organizerProvider) {
    return _certificates.where((cert) {
      // 1. Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final orgName = organizerProvider.getOrganizerName(cert.organizerId).toLowerCase();
        final title = cert.title.toLowerCase();
        final desc = (cert.description ?? '').toLowerCase();
        final certNo = (cert.certificateNumber ?? '').toLowerCase();

        final matches = title.contains(query) ||
            orgName.contains(query) ||
            desc.contains(query) ||
            certNo.contains(query);

        if (!matches) return false;
      }

      // 2. Category filter
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (cert.category.toLowerCase() != _selectedCategory!.toLowerCase()) {
          return false;
        }
      }

      // 3. Organizer filter
      if (_selectedOrganizerId != null && _selectedOrganizerId!.isNotEmpty) {
        if (cert.organizerId != _selectedOrganizerId) {
          return false;
        }
      }

      // 4. Year filter
      if (_selectedYear != null) {
        if (cert.issueDate.year != _selectedYear) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'oldest':
            return a.issueDate.compareTo(b.issueDate);
          case 'a-z':
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case 'z-a':
            return b.title.toLowerCase().compareTo(a.title.toLowerCase());
          case 'newest':
          default:
            return b.issueDate.compareTo(a.issueDate);
        }
      });
  }

  // Favorite certificates
  List<Certificate> get favoriteCertificates {
    final list = _certificates.where((c) => c.isFavorite).toList();
    list.sort((a, b) => b.issueDate.compareTo(a.issueDate));
    return list;
  }

  // Recent certificates (top 5)
  List<Certificate> get recentCertificates {
    final list = List<Certificate>.from(_certificates);
    list.sort((a, b) => b.issueDate.compareTo(a.issueDate));
    return list.take(5).toList();
  }

  // Timeline certificates (sorted by issueDate descending)
  List<Certificate> get timelineCertificates {
    final list = List<Certificate>.from(_certificates);
    list.sort((a, b) => b.issueDate.compareTo(a.issueDate));
    return list;
  }

  // Get distinct years for filter
  List<int> get availableYears {
    final years = _certificates.map((c) => c.issueDate.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  // Organizer counts
  int getCertificateCountByOrganizer(String organizerId) {
    return _certificates.where((c) => c.organizerId == organizerId).length;
  }

  List<Certificate> getCertificatesByOrganizer(String organizerId) {
    return _certificates.where((c) => c.organizerId == organizerId).toList();
  }

  // CRUD Operations
  Future<void> addCertificate(Certificate cert) async {
    _certificates.insert(0, cert);
    await _repository.saveCertificates(_certificates);
    notifyListeners();
  }

  Future<void> updateCertificate(Certificate updated) async {
    final index = _certificates.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _certificates[index] = updated;
      await _repository.saveCertificates(_certificates);
      notifyListeners();
    }
  }

  Future<void> deleteCertificate(String id) async {
    final cert = _certificates.firstWhere((c) => c.id == id, orElse: () => throw Exception('Sertifikat tidak ditemukan'));
    
    // Delete local file if created inside app storage
    try {
      if (!cert.filePath.startsWith('assets/')) {
        final f = File(cert.filePath);
        if (await f.exists()) {
          await f.delete();
        }
      }
    } catch (_) {
      // Ignore file deletion error to prevent blocking metadata deletion
    }

    _certificates.removeWhere((c) => c.id == id);
    await _repository.saveCertificates(_certificates);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _certificates.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = _certificates[index];
      _certificates[index] = current.copyWith(isFavorite: !current.isFavorite);
      await _repository.saveCertificates(_certificates);
      notifyListeners();
    }
  }

  // Statistics Computations
  Map<String, int> getCategoryDistribution() {
    final Map<String, int> result = {};
    for (final cert in _certificates) {
      result[cert.category] = (result[cert.category] ?? 0) + 1;
    }
    return result;
  }

  Map<int, int> getYearDistribution() {
    final Map<int, int> result = {};
    for (final cert in _certificates) {
      final y = cert.issueDate.year;
      result[y] = (result[y] ?? 0) + 1;
    }
    return result;
  }

  Map<String, int> getOrganizerDistribution() {
    final Map<String, int> result = {};
    for (final cert in _certificates) {
      result[cert.organizerId] = (result[cert.organizerId] ?? 0) + 1;
    }
    return result;
  }

  // Reset demo data
  Future<void> resetToDummyData(OrganizerProvider organizerProvider) async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.seedInitialData();
      await organizerProvider.loadOrganizers();
      _certificates = await _repository.getCertificates();
      resetFilters();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
