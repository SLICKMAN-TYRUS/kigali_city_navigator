// presentation/screens/detail/add_edit_listing_screen.dart
// Form to create new listing or edit existing one
// Includes all required fields: name, category, address, phone, description, coordinates

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/providers/listing_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';

class AddEditListingScreen extends StatefulWidget {
  final ListingModel? listing; // Null = create, Not null = edit

  const AddEditListingScreen({
    super.key,
    this.listing,
  });

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    // If editing, populate fields
    if (widget.listing != null) {
      _nameController.text = widget.listing!.name;
      _addressController.text = widget.listing!.address;
      _phoneController.text = widget.listing!.contactNumber;
      _descriptionController.text = widget.listing!.description;
      _latController.text = widget.listing!.latitude.toString();
      _lngController.text = widget.listing!.longitude.toString();
      _selectedCategory = widget.listing!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    final listingProvider =
        Provider.of<ListingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      return;
    }

    // Parse coordinates
    final lat = double.tryParse(_latController.text) ?? 0.0;
    final lng = double.tryParse(_lngController.text) ?? 0.0;

    final listing = ListingModel(
      id: widget.listing?.id ?? '', // Empty for new, existing for edit
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      address: _addressController.text.trim(),
      contactNumber: _phoneController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: lat,
      longitude: lng,
      createdBy: userId,
      timestamp: widget.listing?.timestamp ?? DateTime.now(),
    );

    bool success;
    if (widget.listing == null) {
      // Create new
      success = await listingProvider.createListing(listing);
    } else {
      // Update existing
      success = await listingProvider.updateListing(listing);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.listing == null
              ? Constants.successListingCreated
              : Constants.successListingUpdated),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    final isEditing = widget.listing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add New Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error message
              if (listingProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    listingProvider.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Place Name *',
                  hintText: 'e.g., Kigali Public Library',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Constants.errorRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                ),
                items: Constants.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  hintText: 'Full street address',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Constants.errorRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number *',
                  hintText: '+250 7XX XXX XXX',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Constants.errorRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe this place...',
                ),
                maxLines: 4,
                maxLength: Constants.maxDescriptionLength,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Constants.errorRequired;
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Coordinates section
              Text(
                'Location Coordinates *',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Latitude
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '-1.9441',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < -90 || num > 90) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Longitude
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '30.0619',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < -180 || num > 180) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Use Google Maps to find coordinates (right-click on map)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: listingProvider.isLoading ? null : _saveListing,
                child: listingProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEditing ? 'Update Listing' : 'Create Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
