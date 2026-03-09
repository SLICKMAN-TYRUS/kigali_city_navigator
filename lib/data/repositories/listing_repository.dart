// data/repositories/listing_repository.dart
// Abstract interface for listing data operations
// This abstraction allows us to swap Firebase with another backend later
// without changing any UI or state management code

import '../models/listing_model.dart';

abstract class ListingRepository {
  // Get all listings as a real-time stream
  // Stream automatically updates when Firestore data changes
  Stream<List<ListingModel>> getAllListings();
  
  // Get listings created by a specific user (for "My Listings" screen)
  Stream<List<ListingModel>> getUserListings(String userId);
  
  // CRUD operations
  Future<String> createListing(ListingModel listing);
  Future<void> updateListing(ListingModel listing);
  Future<void> deleteListing(String listingId);
  
  // Search functionality (client-side implementation)
  Future<List<ListingModel>> searchListings(String query);
}