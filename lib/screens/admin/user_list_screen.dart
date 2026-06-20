import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/user_provider.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return StreamBuilder<QuerySnapshot>(
      stream: userProvider.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Terjadi kesalahan: ${snapshot.error}',
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada pengguna terdaftar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;
            
            final name = data['name'] ?? 'No Name';
            final email = data['email'] ?? 'No Email';
            final photoUrl = data['photoUrl'];
            final isAdmin = data['isAdmin'] ?? false;

            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    email,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
