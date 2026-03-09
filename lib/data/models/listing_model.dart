// data/models/listing_model.dart
// Represents a service/place listing in Kigali
// Handles conversion between Firestore documents and Dart objects

import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  // Unique document ID from Firestore
  final String id;

  // Basic information
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;

  // Geographic coordinates for map integration
  final double latitude;
  final double longitude;

  // Ownership and metadata
  final String createdBy; // Firebase Auth UID
  final DateTime timestamp;

  ListingModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
  });

  // Factory constructor: creates ListingModel from Firestore document
  // This is used when reading data from Firebase
  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ListingModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      createdBy: data['createdBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Converts ListingModel to Map for saving to Firestore
  // This is used when writing data to Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Creates a copy with modified fields
  // Useful for edit operations where we only change some fields
  ListingModel copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
  }) {
    return ListingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
