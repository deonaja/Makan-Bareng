import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();

  int _maxParticipants = 4;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  LatLng _selectedLocation = const LatLng(-6.9732, 107.6310);
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    _locationAddressController.dispose();
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
    var selectedTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (!selectedTime.isAfter(now)) {
      selectedTime = selectedTime.add(const Duration(days: 1));
    }

    setState(() => _startTime = selectedTime);
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_startTime.isAfter(DateTime.now())) {
      _showSnackBar(
        message: 'Waktu mulai harus setelah waktu sekarang',
        backgroundColor: AppColors.error,
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final sessionProvider = context.read<SessionProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      _showSnackBar(
        message: 'Kamu harus login dulu',
        backgroundColor: AppColors.error,
      );
      return;
    }

    final sessionId = await sessionProvider.createSession(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hostId: currentUser.uid,
      hostName: currentUser.name,
      hostPhotoUrl: currentUser.photoUrl,
      locationName: _locationNameController.text.trim(),
      locationAddress: _locationAddressController.text.trim(),
      locationLatitude: _selectedLocation.latitude,
      locationLongitude: _selectedLocation.longitude,
      scheduledAt: _startTime,
      maxParticipants: _maxParticipants,
    );

    if (!mounted) return;

    if (sessionId != null) {
      _showSnackBar(
        message: 'Sesi makan dibuat!',
        backgroundColor: AppColors.success,
      );
      Navigator.pop(context);
    } else {
      _showSnackBar(
        message: sessionProvider.error ?? 'Gagal membuat sesi',
        backgroundColor: AppColors.error,
      );
    }
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
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
              CustomTextField(
                controller: _titleController,
                labelText: 'Judul Sesi',
                hintText: 'Contoh: Makan Siang Bareng',
                prefixIcon: Icons.title_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Deskripsi',
                hintText: 'Ceritakan tentang sesi makan ini...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text('Lokasi Makan', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _locationNameController,
                labelText: 'Nama Tempat',
                hintText: 'Contoh: Warung Bu Tini',
                prefixIcon: Icons.restaurant_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tempat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationAddressController,
                labelText: 'Alamat',
                hintText: 'Contoh: Jl. Telekomunikasi No. 1',
                prefixIcon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Peta interaktif — tap untuk menandai lokasi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        'Tap pada peta untuk menandai lokasi',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                        onTap: (tapPosition, point) {
                          setState(() => _selectedLocation = point);
                        },
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
                              point: _selectedLocation,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.5),
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
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
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
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maks Peserta', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.remove_rounded, size: 18),
                                onPressed: _maxParticipants > 2
                                    ? () => setState(() => _maxParticipants--)
                                    : null,
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text(
                                '$_maxParticipants',
                                style: AppTextStyles.heading4,
                              ),
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
              CustomButton(
                text: sessionProvider.isLoading
                    ? 'Membuat sesi...'
                    : 'Buat Sesi Makan',
                isLoading: sessionProvider.isLoading,
                onPressed: _createSession,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
