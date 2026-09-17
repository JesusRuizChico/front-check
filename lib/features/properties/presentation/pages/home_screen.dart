import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.home_work_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Arrendamiento'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Return to login for demo purposes
                context.go('/login');
              },
              child: const CircleAvatar(
                backgroundColor: AppColors.surfaceLight,
                radius: 16,
                child: Icon(Icons.person, size: 16, color: AppColors.textLight),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumSearchHero(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recomendados', style: Theme.of(context).textTheme.titleLarge),
                  const Text('Ver todos', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCatalogGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSearchHero(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Encuentra tu',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Lugar Ideal',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por zona (ej. Vista Hermosa)',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                prefixIcon: Icon(Icons.search, color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildPremiumCard(
            title: 'Departamento Vista Hermosa',
            price: '\$3,500',
            location: 'Col. Vista Hermosa',
            isVerified: true,
            imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&q=80&w=400',
            beds: '2',
            water: 'Alta',
          ),
          const SizedBox(height: 20),
          _buildPremiumCard(
            title: 'Cuarto Estudiantil',
            price: '\$1,800',
            location: 'Cerca de UT',
            isVerified: true,
            imageUrl: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&q=80&w=400',
            beds: '1',
            water: 'Regular',
          ),
          const SizedBox(height: 20),
          _buildPremiumCard(
            title: 'Edificio Centro',
            price: '\$4,200',
            location: 'Centro Histórico',
            isVerified: false,
            imageUrl: 'https://images.unsplash.com/photo-1460317442991-0ec209397118?auto=format&fit=crop&q=80&w=400',
            beds: '3',
            water: 'Alta',
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required String price,
    required String location,
    required bool isVerified,
    required String imageUrl,
    required String beds,
    required String water,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: AppColors.background,
                    child: const Center(child: Icon(Icons.image, size: 50, color: AppColors.surfaceLight)),
                  ),
                ),
              ),
              if (isVerified)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Verificada', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildFeatureIcon(Icons.bed, '$beds Hab'),
                        const SizedBox(width: 16),
                        _buildFeatureIcon(Icons.water_drop, water),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text('Contactar'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.accent),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
