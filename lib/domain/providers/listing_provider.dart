// domain/providers/listing_provider.dart
// Manages listing data state - CRUD operations, search, and filtering
// Provides real-time streams to UI widgets

import 'package:flutter/foundation.dart';
import '../../data/models/listing_model.dart';
import '../../data/repositories/listing_repository.dart';

class ListingProvider extends ChangeNotifier {
  final ListingRepository _listingRepo;

  // Cached data
  List<ListingModel> _listings = [];
  List<ListingModel> _myListings = [];

  // UI state
  bool _isLoading = false;
  String? _error;

  // Search and filter state
  String _searchQuery = '';
  String? _selectedCategory;

  // Constructor
  ListingProvider(this._listingRepo);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  // Filtered listings for Directory screen
  List<ListingModel> get listings {
    return _listings.where((listing) {
      final matchesSearch = _searchQuery.isEmpty ||
          listing.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || listing.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // User's own listings
  List<ListingModel> get myListings => _myListings;

  // Real-time streams for StreamBuilder widgets
  Stream<List<ListingModel>> get allListingsStream =>
      _listingRepo.getAllListings();

  Stream<List<ListingModel>> getMyListingsStream(String userId) =>
      _listingRepo.getUserListings(userId);

  // Update cached listings from stream
  void setListings(List<ListingModel> listings) {
    _listings = listings;
    notifyListeners();
  }

  void setMyListings(List<ListingModel> listings) {
    _myListings = listings;
    notifyListeners();
  }

  // Create new listing
  Future<bool> createListing(ListingModel listing) async {
    _setLoading(true);
    _clearError();

    try {
      await _listingRepo.createListing(listing);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update existing listing
  Future<bool> updateListing(ListingModel listing) async {
    _setLoading(true);
    _clearError();

    try {
      await _listingRepo.updateListing(listing);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete listing
  Future<bool> deleteListing(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _listingRepo.deleteListing(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Search by name
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter by category
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
