class Budget {
  final int? id;
  final int categoryId;
  final double amount;
  final int month; // 1-12
  final int year;

  Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['category_id'],
      amount: (map['amount'] as num).toDouble(),
      month: map['month'],
      year: map['year'],
    );
  }
}
