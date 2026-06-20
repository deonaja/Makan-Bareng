import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
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
  late TextEditingController _prefController;
  late List<String> _selectedPreferences;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _bioController = TextEditingController(text: user.bio);
    _prefController = TextEditingController();
    _selectedPreferences = List.from(user.foodPreferences);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _prefController.dispose();
    super.dispose();
  }

  void _addPreference() {
    final text = _prefController.text.trim();
    if (text.isNotEmpty && !_selectedPreferences.contains(text)) {
      setState(() {
        _selectedPreferences.add(text);
        _prefController.clear();
      });
    }
  }

  void _removePreference(String pref) {
    setState(() {
      _selectedPreferences.remove(pref);
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  bool _isLoading = false;

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    
    try {
      String? uploadedPhotoUrl = user.photoUrl;

      if (_selectedImage != null) {
        uploadedPhotoUrl = await userProvider.uploadProfilePicture(_selectedImage!);
      }

      final updatedUser = auth.currentUser!.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        foodPreferences: _selectedPreferences,
        photoUrl: uploadedPhotoUrl,
      );
      
      await userProvider.updateUserProfile(user: updatedUser);
      auth.updateProfile(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                GestureDetector(
                  onTap: _pickImage,
                  child: _selectedImage != null
                      ? ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        )
                      : AvatarWidget(
                          name: user.name,
                          photoUrl: user.photoUrl,
                          size: 88,
                          showBorder: true,
                        ),
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
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _prefController,
                    hintText: 'Tambah (mis: Nasi Padang)',
                    prefixIcon: Icons.fastfood_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _addPreference,
                    icon: const Icon(Icons.add),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedPreferences.map((pref) {
                  return Chip(
                    label: Text(
                      pref,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    side: BorderSide(color: AppColors.primary),
                    deleteIconColor: AppColors.primary,
                    onDeleted: () => _removePreference(pref),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            _isLoading 
              ? const CircularProgressIndicator()
              : CustomButton(
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
