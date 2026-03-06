// presentation/screens/main/map_view_screen.dart
// Shows all listings as markers on Google Map
// Tapping marker shows info window, tapping info window opens detail

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/listing_provider.dart';
import '../detail/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  // Default center on Kigali city center
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);
  static const double _defaultZoom = 12;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> _createMarkers(List listings) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListingDetailScreen(listing: listing),
              ),
            );
          },
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        actions: [
          // Recenter button
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController?.animateCamera(
                const CameraUpdate.newLatLngZoom(_kigaliCenter, _defaultZoom),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: listingProvider.allListingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _markers = _createMarkers(snapshot.data!);
          }

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: _defaultZoom,
            ),
            markers: _markers,
            myLocationEnabled: false, // Would need location permission
            myLocationButtonEnabled: false,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
          );
        },
      ),
    );
  }
}
