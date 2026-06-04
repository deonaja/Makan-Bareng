import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../models/restaurant_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final MapController _mapController = MapController();

  int _maxParticipants = 4;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));

  // Daftar 9 resto preset — diambil dari MockData
  static List<RestaurantModel> get _restaurants => MockData.restaurants;
  int _selectedRestoIndex = 0;

  RestaurantModel get _selectedResto => _restaurants[_selectedRestoIndex];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final now = DateTime.now();
    var selected = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!selected.isAfter(now)) {
      selected = selected.add(const Duration(days: 1));
    }
    setState(() => _startTime = selected);
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_startTime.isAfter(DateTime.now())) {
      _showSnackBar('Waktu mulai harus setelah waktu sekarang', AppColors.error);
      return;
    }

    final auth = context.read<AuthProvider>();
    final sessionProvider = context.read<SessionProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      _showSnackBar('Kamu harus login dulu', AppColors.error);
      return;
    }

    final resto = _selectedResto;
    final sessionId = await sessionProvider.createSession(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hostId: currentUser.uid,
      hostName: currentUser.name,
      hostPhotoUrl: currentUser.photoUrl,
      locationName: resto.name,
      locationAddress: resto.address,
      locationLatitude: resto.location.latitude,
      locationLongitude: resto.location.longitude,
      scheduledAt: _startTime,
      maxParticipants: _maxParticipants,
    );

    if (!mounted) return;

    if (sessionId != null) {
      _showSnackBar('Sesi makan dibuat! 🎉', AppColors.success);
      Navigator.pop(context);
    } else {
      _showSnackBar(
        sessionProvider.error ?? 'Gagal membuat sesi',
        AppColors.error,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final sessionProvider = context.watch<SessionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Sesi Makan'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Judul ──────────────────────────────────────────────
              CustomTextField(
                controller: _titleController,
                labelText: 'Judul Sesi',
                hintText: 'Contoh: Makan Siang Bareng 🍛',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              // ── Deskripsi ──────────────────────────────────────────
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Deskripsi',
                hintText: 'Ceritakan tentang sesi makan ini...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ── Pilih Tempat Makan ─────────────────────────────────
              Text('Pilih Tempat Makan', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),

              SizedBox(
                height: 108,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _restaurants.length,
                  itemBuilder: (context, index) {
                    final resto = _restaurants[index];
                    final isSelected = _selectedRestoIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedRestoIndex = index);
                        // Gerakkan peta ke lokasi resto yang dipilih
                        _mapController.move(resto.location, 16.0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 160,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant_rounded,
                                  size: 14,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    resto.name,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              resto.category,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textTertiary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              resto.priceRange,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Info resto terpilih
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedResto.address,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Peta preview (static, update via MapController) ────
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedResto.location,
                    initialZoom: 16.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedResto.location,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Waktu & Peserta ────────────────────────────────────
              Row(
                children: [
                  // Waktu Mulai
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Waktu Mulai', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  timeFormat.format(_startTime),
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Maks Peserta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maks Peserta', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_rounded, size: 18),
                                onPressed: _maxParticipants > 2
                                    ? () => setState(() => _maxParticipants--)
                                    : null,
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('$_maxParticipants',
                                  style: AppTextStyles.heading4),
                              IconButton(
                                icon: const Icon(Icons.add_rounded, size: 18),
                                onPressed: _maxParticipants < 10
                                    ? () => setState(() => _maxParticipants++)
                                    : null,
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Tombol Buat ────────────────────────────────────────
              CustomButton(
                text: 'Buat Sesi Makan 🍽️',
                isLoading: sessionProvider.isLoading,
                onPressed: () => _createSession(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
