import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late List<String> _selectedPreferences;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio);
    _selectedPreferences = List.from(user.foodPreferences);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _togglePreference(String pref) {
    setState(() {
      if (_selectedPreferences.contains(pref)) {
        _selectedPreferences.remove(pref);
      } else {
        _selectedPreferences.add(pref);
      }
    });
  }

  void _saveProfile() {
    final auth = context.read<AuthProvider>();
    final updatedUser = auth.currentUser!.copyWith(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      foodPreferences: _selectedPreferences,
    );
    auth.updateProfile(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui! ✅'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                AvatarWidget(
                  name: user.name,
                  size: 88,
                  showBorder: true,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.background, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Name
            CustomTextField(
              controller: _nameController,
              labelText: 'Nama',
              hintText: 'Masukkan nama lengkap',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // Bio
            CustomTextField(
              controller: _bioController,
              labelText: 'Bio',
              hintText: 'Ceritakan tentang dirimu...',
              prefixIcon: Icons.info_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Email (read only)
            CustomTextField(
              labelText: 'Email',
              hintText: user.email,
              prefixIcon: Icons.email_outlined,
              enabled: false,
            ),
            const SizedBox(height: 28),

            // Food preferences
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Preferensi Makanan',
                  style: AppTextStyles.labelLarge),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MockData.foodPreferenceOptions.map((pref) {
                final isSelected = _selectedPreferences.contains(pref);
                return GestureDetector(
                  onTap: () => _togglePreference(pref),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      pref,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Save button
            CustomButton(
              text: 'Simpan Perubahan',
              onPressed: _saveProfile,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
