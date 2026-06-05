import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';

class RestaurantFormScreen extends StatefulWidget {
  final String? restaurantId;
  final Map<String, dynamic>? initialData;

  const RestaurantFormScreen({
    super.key,
    this.restaurantId,
    this.initialData,
  });

  @override
  State<RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends State<RestaurantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;

  String _priceRange = 'Sedang';
  List<String> _categories = [];

  bool get isEditMode => widget.restaurantId != null && widget.initialData != null;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    
    _nameController = TextEditingController(text: data?['name'] ?? '');
    _descriptionController = TextEditingController(text: data?['description'] ?? '');
    _addressController = TextEditingController(text: data?['address'] ?? '');
    
    final location = data?['location'] as Map<String, dynamic>?;
    _latitudeController = TextEditingController(text: location?['latitude']?.toString() ?? '');
    _longitudeController = TextEditingController(text: location?['longitude']?.toString() ?? '');
    
    _imageUrlController = TextEditingController(text: data?['imageUrl'] ?? '');
    _categoryController = TextEditingController();

    if (data?['categories'] != null) {
      _categories = List<String>.from(data!['categories']);
    }
    
    if (data?['priceRange'] != null) {
      _priceRange = data!['priceRange'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final text = _categoryController.text.trim();
    if (text.isNotEmpty && !_categories.contains(text)) {
      setState(() {
        _categories.add(text);
        _categoryController.clear();
      });
    }
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 kategori makanan')),
      );
      return;
    }

    final provider = context.read<RestaurantProvider>();
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.uid ?? '';

    final lat = double.tryParse(_latitudeController.text) ?? 0.0;
    final lng = double.tryParse(_longitudeController.text) ?? 0.0;

    try {
      if (isEditMode) {
        await provider.updateRestaurant(
          widget.restaurantId!,
          {
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'address': _addressController.text.trim(),
            'location': {
              'latitude': lat,
              'longitude': lng,
            },
            'categories': _categories,
            'priceRange': _priceRange,
            'imageUrl': _imageUrlController.text.trim(),
          },
        );
      } else {
        await provider.addRestaurant(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          address: _addressController.text.trim(),
          latitude: lat,
          longitude: lng,
          categories: _categories,
          priceRange: _priceRange,
          imageUrl: _imageUrlController.text.trim(),
          createdBy: currentUserId,
        );
      }

      if (mounted) {
        if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage!)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditMode ? 'Restoran diperbarui' : 'Restoran ditambahkan')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RestaurantProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(isEditMode ? 'Edit Restoran' : 'Tambah Restoran', style: AppTextStyles.heading3),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Restoran',
                  icon: Icons.restaurant_menu,
                  validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Alamat',
                  icon: Icons.location_on,
                  validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _latitudeController,
                        label: 'Latitude',
                        icon: Icons.explore,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _longitudeController,
                        label: 'Longitude',
                        icon: Icons.explore,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'URL Gambar (Gmaps photo dll)',
                  icon: Icons.image,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priceRange,
                  decoration: InputDecoration(
                    labelText: 'Rentang Harga',
                    prefixIcon: const Icon(Icons.attach_money, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                  dropdownColor: AppColors.surfaceLight,
                  items: ['Murah', 'Sedang', 'Mahal']
                      .map((val) => DropdownMenuItem(value: val, child: Text(val, style: TextStyle(color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _priceRange = val);
                  },
                ),
                const SizedBox(height: 24),
                
                Text('Kategori Makanan', style: AppTextStyles.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _categoryController,
                        label: 'Misal: Nasi Padang',
                        icon: Icons.fastfood,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) => Chip(
                    label: Text(cat, style: const TextStyle(color: AppColors.textPrimary)),
                    backgroundColor: AppColors.surfaceLight,
                    deleteIconColor: AppColors.error,
                    onDeleted: () => setState(() => _categories.remove(cat)),
                  )).toList(),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _saveRestaurant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEditMode ? 'Simpan Perubahan' : 'Tambah Restoran',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
