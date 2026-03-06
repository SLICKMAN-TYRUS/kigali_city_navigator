// data/services/firestore_listing_service.dart
// Concrete implementation of ListingRepository using Firebase Firestore
// This is the ONLY file in the app that directly calls Firestore APIs

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../repositories/listing_repository.dart';

class FirestoreListingService implements ListingRepository {
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for listings
  CollectionReference get _listings => _firestore.collection('listings');

  @override
  Stream<List<ListingModel>> getAllListings() {
    // Order by newest first for the directory screen
    // This returns a real-time stream that updates automatically
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<ListingModel>> getUserListings(String userId) {
    // Filter by createdBy field and order by timestamp
    // Used for "My Listings" screen
    return _listings
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<String> createListing(ListingModel listing) async {
    try {
      // Add document to Firestore, returns DocumentReference
      final docRef = await _listings.add(listing.toFirestore());
      return docRef.id; // Return the auto-generated document ID
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  @override
  Future<void> updateListing(ListingModel listing) async {
    try {
      // Update existing document by ID
      await _listings.doc(listing.id).update(listing.toFirestore());
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  @override
  Future<void> deleteListing(String listingId) async {
    try {
      // Delete document by ID
      await _listings.doc(listingId).delete();
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  @override
  Future<List<ListingModel>> searchListings(String query) async {
    // Note: Firestore doesn't support native full-text search
    // For production, consider Algolia or ElasticSearch
    // This implementation fetches all and filters locally

    try {
      final snapshot = await _listings.get();
      final allListings =
          snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList();

      // Case-insensitive search on name field
      final lowerQuery = query.toLowerCase();
      return allListings.where((listing) {
        return listing.name.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }
}
