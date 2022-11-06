import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final weekDayProvider = Provider((ref) => 7);
final colorProvider = Provider((ref) => Colors.grey);
final monthDurationProvider = StateProvider((ref) => 0);
final todayProvider = Provider((ref) => DateTime.now());
final focusedDayProvider = StateProvider((ref) => DateTime.now());

class Calendar extends ConsumerStatefulWidget {
  const Calendar({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  final bool isDisplayFooter = false;
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CalendarHeader(),
        DayOfWeekCell(),
        const CalendarBody(),
      ],
    );
  }
}

class CalendarHeader extends ConsumerWidget {
  const CalendarHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("カレンダー"),
          // GestureDetector(
          //   child: const Icon(
          //     Icons.arrow_left,
          //     size: 30,
          //     color: Colors.white,
          //   ),
          //   onTap: () {
          //     ref
          //         .read(monthDurationProvider.notifier)
          //         .update((state) => state++);
          //   },
          // )
        ],
      ),
    );
  }
}

class DayOfWeekCell extends ConsumerWidget {
  final List<String> weekName = ['月', '火', '水', '木', '金', '土', '日'];

  DayOfWeekCell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> weekList = [];
    int counter = 0;
    final weekState = ref.watch(weekDayProvider);
    int weekIndex = weekState - 1;
    final color = ref.watch(colorProvider);

    while (counter < 7) {
      weekList.add(Expanded(
          child: Container(
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            weekName[weekIndex % 7],
            textAlign: TextAlign.center,
          ),
        ),
      )));
      counter++;
      weekIndex++;
    }
    return Row(
      children: weekList,
    );
  }
}

class CalendarBody extends ConsumerWidget {
  const CalendarBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekDay = ref.watch(weekDayProvider);
    final monthDuration = ref.watch(monthDurationProvider);
    List<Widget> list = [];
    DateTime now = DateTime.now();
    DateTime firstDayOfTheMonth =
        DateTime(now.year, now.month + monthDuration, 1);
    int monthLastNumber =
        DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month + 1, 1)
            .add(const Duration(days: -1))
            .day;
    int previousMonthLastNumber =
        DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month, 1)
            .add(const Duration(days: -1))
            .day;
    int nextMonthFirstNumber =
        DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month + 1, 1).day;
    List<Widget> listCache = [];
    for (int i = 1; i <= monthLastNumber; i++) {
      listCache.add(Expanded(
          child: BuildCalendarItem(i,
              DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month, i))));

      if (DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month, i)
                  .weekday ==
              newLineNumber(startNumber: weekDay) ||
          i == monthLastNumber) {
        int repeatNumber = 7 - listCache.length;
        for (int j = 0; j < repeatNumber; j++) {
          if (DateTime(firstDayOfTheMonth.year, firstDayOfTheMonth.month, i)
                  .day <=
              7) {
            listCache.insert(
                0,
                Expanded(
                  child: BuildCalendarItem(
                      previousMonthLastNumber - j,
                      DateTime(
                          firstDayOfTheMonth.year,
                          firstDayOfTheMonth.month - 1,
                          previousMonthLastNumber - j)),
                ));
          } else {
            listCache.add(Expanded(
              child: BuildCalendarItem(
                  nextMonthFirstNumber + j,
                  DateTime(firstDayOfTheMonth.year,
                      firstDayOfTheMonth.month + 1, nextMonthFirstNumber + j)),
            ));
          }
        }
        list.add(Row(
          children: listCache,
        ));
        listCache = [];
      }
    }

    return Column(
      children: list,
    );
  }

  int newLineNumber({required int startNumber}) {
    if (startNumber == 1) return 7;
    return startNumber - 1;
  }
}

Border buildBorder() => Border.all(width: 0.1, color: Colors.grey);

class BuildCalendarItem extends ConsumerWidget {
  final int index;
  final DateTime cacheDate;

  const BuildCalendarItem(this.index, this.cacheDate, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowDate = ref.watch(todayProvider);
    bool isToday = (nowDate.difference(cacheDate).inDays == 0) &&
        (nowDate.day == cacheDate.day);
    bool isOutsideDay = (nowDate.month != cacheDate.month);
    if (isToday) {
      return Container(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: Text(
            '$index',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    if (isOutsideDay) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            border: buildBorder(),
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            alignment: Alignment.center,
            width: 30,
            height: 30,
            child: Text(
              '$index',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.blueGrey[100],
              ),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          border: buildBorder(),
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          width: 30,
          height: 30,
          child: Text(
            '$index',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: _textDayColor(cacheDate),
            ),
          ),
        ),
      ),
    );
  }

  Color _textDayColor(DateTime day) {
    const defaultTextColor = Colors.black87;

    if (day.weekday == DateTime.sunday) {
      return Colors.red;
    }
    if (day.weekday == DateTime.saturday) {
      return Colors.blue[600]!;
    }
    return defaultTextColor;
  }
}
