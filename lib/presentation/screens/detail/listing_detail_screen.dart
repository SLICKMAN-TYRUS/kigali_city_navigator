// presentation/screens/detail/listing_detail_screen.dart
// Shows full details of a listing with embedded map
// Provides navigation button to open Google Maps

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/models/listing_model.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

  // Launch Google Maps for turn-by-turn navigation
  Future<void> _launchNavigation() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${listing.latitude},${listing.longitude}'
      '&destination_place_id=${Uri.encodeComponent(listing.name)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // Launch phone dialer
  Future<void> _launchPhone() async {
    final url = Uri.parse('tel:${listing.contactNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Embedded Google Map
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(listing.latitude, listing.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(listing.id),
                    position: LatLng(listing.latitude, listing.longitude),
                    infoWindow: InfoWindow(title: listing.name),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Chip(
                    avatar: Icon(
                      _getCategoryIcon(listing.category),
                      size: 18,
                    ),
                    label: Text(listing.category),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    listing.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),

                  // Address with navigation button
                  _buildInfoRow(
                    icon: Icons.location_on,
                    text: listing.address,
                    action: ElevatedButton.icon(
                      onPressed: _launchNavigation,
                      icon: const Icon(Icons.navigation),
                      label: const Text('Directions'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone number
                  _buildInfoRow(
                    icon: Icons.phone,
                    text: listing.contactNumber,
                    action: TextButton(
                      onPressed: _launchPhone,
                      child: const Text('Call'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Metadata
                  Text(
                    'Added on ${_formatDate(listing.timestamp)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    Widget? action,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return FontAwesomeIcons.hospital;
      case 'Police Station':
        return FontAwesomeIcons.buildingShield;
      case 'Library':
        return FontAwesomeIcons.book;
      case 'Restaurant':
        return FontAwesomeIcons.utensils;
      case 'Café':
        return FontAwesomeIcons.mugHot;
      case 'Park':
        return FontAwesomeIcons.tree;
      case 'Tourist Attraction':
        return FontAwesomeIcons.camera;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
