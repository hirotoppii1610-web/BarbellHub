import 'logged_food.dart';

class HistoryLog {
  final LoggedFood foodLog;
  final DateTime date;

  const HistoryLog({
    required this.foodLog,
    required this.date,
  });
}