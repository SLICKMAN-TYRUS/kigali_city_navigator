// presentation/screens/main/my_listings_screen.dart
// Shows listings created by the current user
// Allows edit and delete operations

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/listing_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../detail/listing_detail_screen.dart';
import '../detail/add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Center(child: Text('Please log in to view your listings'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: StreamBuilder(
        stream: listingProvider.getMyListingsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Update provider cache
          WidgetsBinding.instance.addPostFrameCallback((_) {
            listingProvider.setMyListings(snapshot.data!);
          });

          final listings = listingProvider.myListings;

          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t created any listings yet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddEditListingScreen(),
                        ),
                      );
                    },
                    child: const Text('Create Your First Listing'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return ListingCard(
                listing: listing,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: listing),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditListingScreen(listing: listing),
                    ),
                  );
                },
                onDelete: () =>
                    _confirmDelete(context, listingProvider, listing.id),
                isOwner: true,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditListingScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ListingProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteListing(id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
