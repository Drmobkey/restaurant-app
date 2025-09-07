import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/restaurant_detail.dart' as models;
import '../providers/restaurant_provider.dart';
import '../services/api_service.dart';
import '../widgets/error_widget.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(
      'DetailScreen: Initializing with restaurant ID: ${widget.restaurantId}',
    ); // Debug log
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RestaurantProvider>();
      // Reset state sebelum fetch baru
      provider.resetRestaurantDetailState();
      provider.fetchRestaurantDetail(widget.restaurantId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          final state = provider.restaurantDetailState;

          // Perbaiki nama class state (hapus prefix models.)
          if (state is RestaurantDetailLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Loading...'),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat detail restoran...'),
                  ],
                ),
              ),
            );
          } else if (state is RestaurantDetailError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: CustomErrorWidget(
                message: state.message,
                onRetry: () =>
                    provider.fetchRestaurantDetail(widget.restaurantId),
              ),
            );
          } else if (state is RestaurantDetailLoaded) {
            return _buildDetailContent(state.restaurant);
          }

          // Default case untuk RestaurantDetailInitial
          return Scaffold(
            appBar: AppBar(title: const Text('Restaurant Detail')),
            body: const Center(child: Text('Initializing...')),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(models.RestaurantDetail restaurant) {
    return CustomScrollView(
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Hero(
              tag: 'restaurant-name-${restaurant.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            background: Hero(
              tag: 'restaurant-image-${restaurant.id}',
              child: CachedNetworkImage(
                imageUrl: ApiService.getImageUrl(
                  restaurant.pictureId,
                  size: 'large',
                ),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 50),
                ),
              ),
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfo(restaurant),
                const SizedBox(height: 24),
                _buildDescription(restaurant),
                const SizedBox(height: 24),
                _buildMenus(restaurant),
                const SizedBox(height: 24),
                _buildReviews(restaurant),
                const SizedBox(height: 24),
                _buildAddReviewSection(restaurant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(models.RestaurantDetail restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  restaurant.rating.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${restaurant.address}, ${restaurant.city}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant.categories.map((c) => c.name).join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(models.RestaurantDetail restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              restaurant.description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenus(models.RestaurantDetail restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Foods
        _buildMenuSection('Makanan', restaurant.menus.foods),
        const SizedBox(height: 16),
        // Drinks
        _buildMenuSection('Minuman', restaurant.menus.drinks),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<models.MenuItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Chip(
                  label: Text(item.name),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews(models.RestaurantDetail restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review (${restaurant.customerReviews.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...restaurant.customerReviews.map((review) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Text(review.name[0].toUpperCase())),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.name,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              review.date,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.review,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAddReviewSection(models.RestaurantDetail restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Review',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Review',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitReview(restaurant.id),
                child: const Text('Kirim Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(String restaurantId) async {
    if (_nameController.text.trim().isEmpty ||
        _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan review tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await context.read<RestaurantProvider>().addReview(
        restaurantId,
        _nameController.text.trim(),
        _reviewController.text.trim(),
      );

      _nameController.clear();
      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan review'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
