class Transaction {
  final int? id;
  final int categoryId;
  final double amount;
  final String? note;
  final DateTime date;
  final String type; // 'income' atau 'expense'

  Transaction({
    this.id,
    required this.categoryId,
    required this.amount,
    this.note,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      categoryId: map['category_id'],
      amount: map['amount'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}