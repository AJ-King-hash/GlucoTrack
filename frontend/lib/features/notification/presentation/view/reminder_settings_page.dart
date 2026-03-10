import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/features/notification/presentation/manager/notification_cubit.dart';
import 'package:untitled10/features/notification/presentation/manager/notification_state.dart';

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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotificationCubit>(),
      child: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is ReminderSettingsUpdated) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          } else if (state is NotificationError) {
            Fluttertoast.showToast(
              msg: state.message,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
            );
          }
        },
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
                  _buildSectionTitle('Timezone'),
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
