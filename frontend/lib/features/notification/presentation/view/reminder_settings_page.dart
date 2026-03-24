import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/injection_container.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:glucotrack/features/notification/presentation/manager/notification_cubit.dart';
import 'package:glucotrack/features/notification/presentation/manager/notification_state.dart';
import 'package:glucotrack/features/user/presentation/manager/user_cubit.dart';
import 'package:glucotrack/features/user/presentation/manager/user_state.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  TimeOfDay? _medicineTime;
  TimeOfDay? _glucoTime;
  String _selectedTimezone = 'Asia/Riyadh';

  final List<String> _timezones = [
    'Asia/Riyadh',
    'Asia/Dubai',
    'UTC',
    'America/New_York',
    'Europe/London',
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettingsFromUser();
    });
  }

  void _loadSettingsFromUser() {
    // Check if mounted before using context
    if (!mounted) return;

    // load the user.
    context.read<UserCubit>().getUser();

    try {
      final userState = context.read<UserCubit>().state;
      if (userState is UserLoaded) {
        final user = userState.userModel;

        // Parse medicine time if available
        if (user.medicineTime != null && user.medicineTime!.isNotEmpty) {
          final parts = user.medicineTime!.split(':');
          if (parts.length == 2) {
            _medicineTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }

        // Parse gluco time if available
        if (user.glucoTime != null && user.glucoTime!.isNotEmpty) {
          final parts = user.glucoTime!.split(':');
          if (parts.length == 2) {
            _glucoTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }

        // Set timezone if available (user model should have this field)
        // For now we keep the default, but you can add timezone to UserModel if needed

        // Trigger rebuild to display loaded values
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      // If UserCubit is not available, use defaults
      debugPrint('Error loading settings from UserCubit: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotificationCubit>(),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final locale = context.read<LocaleCubit>();
          return Scaffold(
            backgroundColor: AppColor.backgroundNeutral,
            appBar: AppBar(
              title: Text(locale.translate('reminders')),
              backgroundColor: AppColor.positive,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(locale.translate('medicine_reminder')),
                  const SizedBox(height: 8),
                  _buildTimePickerCard(
                    context: context,
                    icon: Icons.medication,
                    title: locale.translate('medicine_reminder'),
                    subtitle: 'Time to take your medicine',
                    time: _medicineTime,
                    onTap: () => _selectTime(context, isMedicine: true),
                    onClear: () => setState(() => _medicineTime = null),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(locale.translate('sugar_reminder')),
                  const SizedBox(height: 8),
                  _buildTimePickerCard(
                    context: context,
                    icon: Icons.bloodtype,
                    title: locale.translate('sugar_reminder'),
                    subtitle: 'Time to check your blood sugar',
                    time: _glucoTime,
                    onTap: () => _selectTime(context, isMedicine: false),
                    onClear: () => setState(() => _glucoTime = null),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(locale.translate('timezone')),
                  const SizedBox(height: 8),
                  _buildTimezoneSelector(),
                  const SizedBox(height: 32),
                  _buildSaveButton(context),
                  const SizedBox(height: 16),
                  _buildTestButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColor.textNeutral,
      ),
    );
  }

  Widget _buildTimePickerCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.positive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColor.positive, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textNeutral,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time != null ? time.format(context) : subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            time != null ? AppColor.info : AppColor.textNeutral,
                      ),
                    ),
                  ],
                ),
              ),
              if (time != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: AppColor.textNeutral),
                  onPressed: onClear,
                ),
              const Icon(Icons.chevron_right, color: AppColor.textNeutral),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimezoneSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField<String>(
          initialValue: _selectedTimezone,
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.public, color: AppColor.positive),
          ),
          items:
              _timezones.map((tz) {
                return DropdownMenuItem(value: tz, child: Text(tz));
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedTimezone = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final cubit = context.read<NotificationCubit>();

          String? glucoTime;
          String? medicineTime;

          if (_glucoTime != null) {
            glucoTime =
                '${_glucoTime!.hour.toString().padLeft(2, '0')}:${_glucoTime!.minute.toString().padLeft(2, '0')}';
          }

          if (_medicineTime != null) {
            medicineTime =
                '${_medicineTime!.hour.toString().padLeft(2, '0')}:${_medicineTime!.minute.toString().padLeft(2, '0')}';
          }

          cubit.updateReminders(
            glucoTime: glucoTime,
            medicineTime: medicineTime,
            timezone: _selectedTimezone,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.positive,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          context.read<LocaleCubit>().translate('save'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          context.read<NotificationCubit>().triggerReminders();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.positive,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColor.positive),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Test Notifications',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context, {
    required bool isMedicine,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isMedicine
              ? (_medicineTime ?? TimeOfDay.now())
              : (_glucoTime ?? TimeOfDay.now()),
    );

    if (picked != null) {
      setState(() {
        if (isMedicine) {
          _medicineTime = picked;
        } else {
          _glucoTime = picked;
        }
      });
    }
  }
}
