// core/utils/constants.dart
// App-wide constants for categories, validation, and messages

class Constants {
  // Categories as per assignment requirements
  static const List<String> categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Utility Office',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
  ];

  // Validation rules
  static const int minPasswordLength = 6;
  static const int maxDescriptionLength = 500;
  static const String phonePattern = r'^[\d\s\-\+\(\)]{8,20}$';

  // App info
  static const String appName = 'Kigali City Navigator';
  static const String tagline = 'Find essential services around you';

  // Error messages
  static const String errorRequired = 'This field is required';
  static const String errorEmail = 'Please enter a valid email';
  static const String errorPassword = 'Password must be at least 6 characters';
  static const String errorPhone = 'Please enter a valid phone number';

  // Success messages
  static const String successListingCreated = 'Listing created successfully!';
  static const String successListingUpdated = 'Listing updated successfully!';
  static const String successListingDeleted = 'Listing deleted successfully!';
}
