import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/services/domain/entities/service_schedule_entity.dart';
import 'package:heraj/features/services/presentation/view/confirm_service_order_screen.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/ui.dart';
import 'package:intl/intl.dart';

class BookServiceScreen extends ConsumerStatefulWidget {
  const BookServiceScreen({
    super.key,
    required this.provider,
    required this.service,
  });

  final ServiceProviderEntity provider;
  final ProviderServiceEntity service;

  @override
  ConsumerState<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends ConsumerState<BookServiceScreen> {
  late final ValueNotifier<DateTime> _selectedDate;
  late final ValueNotifier<String?> _selectedTime;

  List<DateTime> get _dates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<DateTime>.generate(7, (i) => today.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    final dates = _dates;
    DateTime initial = dates.first;
    for (final date in dates) {
      if (_slotsFor(date).isNotEmpty) {
        initial = date;
        break;
      }
    }
    _selectedDate = ValueNotifier(initial);
    final slots = _slotsFor(initial);
    _selectedTime = ValueNotifier(slots.isEmpty ? null : slots.first);
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _selectedTime.dispose();
    super.dispose();
  }

  List<String> _slotsFor(DateTime date) {
    return serviceTimeSlots(
      schedule: widget.service.schedule,
      date: date,
    );
  }

  String _dateChipLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayMonth = '${date.day}/${date.month}';
    if (date == today) return '${'Today'.tr} $dayMonth';
    if (date == tomorrow) return '${'Tomorrow'.tr} $dayMonth';
    final locale = Get.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final weekday = DateFormat('EEEE', locale).format(date);
    return '$weekday $dayMonth';
  }

  void _onConfirm() {
    final date = _selectedDate.value;
    final time = _selectedTime.value;
    if (time == null || time.isEmpty) {
      UIHelper.showAlert(
        'Please choose date and time'.tr,
        type: DialogType.warning,
      );
      return;
    }
    Get.to(
      () => ConfirmServiceOrderScreen(
        provider: widget.provider,
        service: widget.service,
        scheduledDate: date,
        scheduledTime: time,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final cost = widget.service.cost;
    final costText =
        cost % 1 == 0 ? cost.toStringAsFixed(0) : cost.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: AppColor.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color: AppColor.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Book now'.tr,
                              textAlign: TextAlign.center,
                              style: AppFont.font16W400Black.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose date and time'.tr,
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColor.lightBorder),
                            boxShadow: [AppColor.lightShadow],
                          ),
                          child: ValueListenableBuilder<DateTime>(
                            valueListenable: _selectedDate,
                            builder: (context, selectedDate, _) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _selectedTime,
                                builder: (context, selectedTime, __) {
                                  final slots = _slotsFor(selectedDate);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date'.tr,
                                        style: AppFont.font14W600Black,
                                      ),
                                      const Gap(8),
                                      SizedBox(
                                        height: 44,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              for (var i = 0;
                                                  i < _dates.length;
                                                  i++) ...[
                                                if (i > 0) const Gap(8),
                                                _DateChip(
                                                  label: _dateChipLabel(
                                                    _dates[i],
                                                  ),
                                                  selected:
                                                      _dates[i] == selectedDate,
                                                  onTap: () {
                                                    _selectedDate.value =
                                                        _dates[i];
                                                    final nextSlots =
                                                        _slotsFor(_dates[i]);
                                                    if (selectedTime == null ||
                                                        !nextSlots.contains(
                                                          selectedTime,
                                                        )) {
                                                      _selectedTime.value =
                                                          nextSlots.isEmpty
                                                              ? null
                                                              : nextSlots.first;
                                                    }
                                                  },
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Gap(16),
                                      Text(
                                        'Time'.tr,
                                        style: AppFont.font14W600Black,
                                      ),
                                      const Gap(8),
                                      if (slots.isEmpty)
                                        Text(
                                          'No time slots available'.tr,
                                          style:
                                              AppFont.font12w400Black.copyWith(
                                            color: AppColor.textGrey,
                                          ),
                                        )
                                      else
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            for (final slot in slots)
                                              _TimeChip(
                                                label: slot,
                                                selected:
                                                    selectedTime == slot,
                                                onTap: () => _selectedTime
                                                    .value = slot,
                                              ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const Gap(24),
                        Text(
                          'Payment details'.tr,
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total amount'.tr,
                                style: AppFont.font14W500Black,
                              ),
                            ),
                            Text(
                              '$costText ${'EGP'.tr}',
                              style: AppFont.font18W700Black.copyWith(
                                color: AppColor.guestOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
            child: CustomFilledButton(
              text: 'Confirm booking'.tr,
              height: 48,
              width: MediaQuery.sizeOf(context).width - 32,
              gradient: AppColor.defaultPrimaryGradient2,
              radius: 30,
              onPressed: _onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

List<String> serviceTimeSlots({
  required List<ServiceScheduleEntity> schedule,
  required DateTime date,
}) {
  ServiceScheduleEntity? daySchedule;
  final apiDay = date.weekday % 7;
  for (final item in schedule) {
    if (item.dayOfWeek == apiDay) {
      daySchedule = item;
      break;
    }
  }
  final opensAt = daySchedule?.opensAt ?? '09:00';
  final closesAt = daySchedule?.closesAt ?? '19:00';
  if (daySchedule?.isClosed == true) return const [];

  final open = _parseHm(opensAt);
  final close = _parseHm(closesAt);
  if (!open.isBefore(close) && open != close) return const [];

  final slots = <String>[];
  var current = open;
  while (!current.isAfter(close)) {
    slots.add(_formatHm(current));
    current = current.add(const Duration(hours: 2));
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selectedDay = DateTime(date.year, date.month, date.day);
  if (selectedDay != today) return slots;

  return slots.where((slot) {
    final parsed = _parseHm(slot);
    final slotTime = DateTime(
      now.year,
      now.month,
      now.day,
      parsed.hour,
      parsed.minute,
    );
    return slotTime.isAfter(now);
  }).toList();
}

DateTime _parseHm(String value) {
  final parts = value.split(':');
  final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 9;
  final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
  return DateTime(2000, 1, 1, hour, minute);
}

String _formatHm(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColor.primary : AppColor.lightBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppFont.font12w400Black.copyWith(
              color: selected ? AppColor.primary : AppColor.textGrey,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 88,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColor.primary : AppColor.lightBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppFont.font14W500Black.copyWith(
              color: selected ? AppColor.primary : AppColor.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}
