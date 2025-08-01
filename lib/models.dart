// Model for an expense
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

// Model for a budget
class Budget {
  final String id;
  final String month;
  final double amount;

  Budget({
    required this.id,
    required this.month,
    required this.amount,
  });
}

// Model for a transaction (manual or imported)
class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final bool isImported;

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.isImported = false,
  });
}

// Model for a salary
class Salary {
  final String id;
  final double amount;
  final DateTime date;

  Salary({
    required this.id,
    required this.amount,
    required this.date,
  });
}

// Model for a user
class User {
  List<String> categories;
  int workingDaysPerMonth;
  int workingHoursPerDay;
  String? profilePicPath;

  User({
    required this.categories,
    required this.workingDaysPerMonth,
    required this.workingHoursPerDay,
    this.profilePicPath,
  });
}
