// presentation/screens/main/directory_screen.dart
// Browse all listings with search and category filtering
// Uses StreamBuilder for real-time Firestore updates

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/providers/listing_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../detail/listing_detail_screen.dart';
import '../detail/add_edit_listing_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali Directory'),
        actions: [
          // Clear filters button (only show if filters active)
          if (listingProvider.searchQuery.isNotEmpty ||
              listingProvider.selectedCategory != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => listingProvider.clearFilters(),
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: listingProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => listingProvider.setSearchQuery(''),
                      )
                    : null,
              ),
              onChanged: (value) => listingProvider.setSearchQuery(value),
            ),
          ),

          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // "All" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: listingProvider.selectedCategory == null,
                    onSelected: (_) => listingProvider.setCategoryFilter(null),
                  ),
                ),
                // Category chips
                ...Constants.categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: listingProvider.selectedCategory == category,
                      onSelected: (selected) {
                        listingProvider.setCategoryFilter(
                          selected ? category : null,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Listings list with real-time updates
          Expanded(
            child: StreamBuilder(
              stream: listingProvider.allListingsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Update provider cache
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  listingProvider.setListings(snapshot.data!);
                });

                final listings = listingProvider.listings;

                if (listings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          listingProvider.searchQuery.isEmpty &&
                                  listingProvider.selectedCategory == null
                              ? 'No listings yet.\nBe the first to add one!'
                              : 'No results found.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
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
                            builder: (_) => ListingDetailScreen(
                              listing: listing,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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
}
