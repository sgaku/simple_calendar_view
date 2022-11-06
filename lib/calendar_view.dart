import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'calendar.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late final PageController calendarController;
  final DateTime firstDay = DateTime(1970, 1, 1);

  @override
  void initState() {
    calendarController = PageController(
        initialPage: _getInitialPageCount(firstDay, DateTime.now()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("カレンダー"),
      ),
      body: PageView.builder(
        onPageChanged: (page) {
          final nowDate = ref.read(todayProvider);
          ref.read(focusedDayProvider.notifier).update((state) {
            final distance = calendarController.initialPage - page;
            return DateTime(nowDate.year, nowDate.month - distance);
          });
        },
        controller: calendarController,
        itemBuilder: (context, index) {
          return const Calendar();
        },
      ),
    );
  }

  int _getInitialPageCount(DateTime first, DateTime initial) {
    final firstCount = first.year * 12 + first.month;
    final initialCount = initial.year * 12 + initial.month;
    return initialCount - firstCount;
  }
}
