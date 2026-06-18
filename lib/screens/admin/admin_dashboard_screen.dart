import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'restaurant_list_screen.dart';
import 'user_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text(
            'Admin Dashboard',
            style: AppTextStyles.heading3,
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            tabs: const [
              Tab(icon: Icon(Icons.restaurant), text: 'Restoran'),
              Tab(icon: Icon(Icons.people), text: 'Daftar User'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RestaurantListScreen(),
            UserListScreen(),
          ],
        ),
      ),
    );
  }
}
