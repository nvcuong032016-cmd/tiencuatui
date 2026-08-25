enum LoanType { savings, lending }
enum BorrowBank { sacombank, vib, vpbank, tpbank, mbbank }
enum CardType { visa, mastercard, jcb }
enum LendingTarget { individual, organization }

String bankLabel(BorrowBank value) => const {
  BorrowBank.sacombank: 'Sacombank',
  BorrowBank.vib: 'VIB',
  BorrowBank.vpbank: 'VPBank',
  BorrowBank.tpbank: 'TPBank',
  BorrowBank.mbbank: 'MB Bank',
}[value]!;

String cardTypeLabel(CardType value) => const {
  CardType.visa: 'Visa',
  CardType.mastercard: 'Mastercard',
  CardType.jcb: 'JCB',
}[value]!;

class CreditCardModel {
  final String? id;
  final String number;
  final String bank;
  final CardType type;
  final String expiry;
  final int graceDays;
  final int statementDay;
  final int paymentDay;
  final int limit;

  CreditCardModel({this.id, required this.number, required this.bank, required this.type, required this.expiry, required this.graceDays, required this.statementDay, required this.paymentDay, required this.limit});

  Map<String, dynamic> toMap() => {'id': id, 'number': number, 'bank': bank, 'type': type.name, 'expiry': expiry, 'grace_days': graceDays, 'statement_day': statementDay, 'payment_day': paymentDay, 'credit_limit': limit};

  factory CreditCardModel.fromMap(Map<String, dynamic> map) => CreditCardModel(id: map['id'] as String?, number: map['number'] as String, bank: map['bank'] as String, type: CardType.values.byName(map['type'] as String), expiry: map['expiry'] as String, graceDays: map['grace_days'] as int, statementDay: map['statement_day'] as int, paymentDay: map['payment_day'] as int, limit: map['credit_limit'] as int);
}

class LoanModel {
  final String? id;
  final String content;
  final BorrowBank bank;
  final int amount;
  final int installments;
  final int monthly;
  final String note;
  final List<bool> paid;

  LoanModel({this.id, required this.content, required this.bank, required this.amount, required this.installments, required this.monthly, required this.note, required this.paid});

  int get paidAmount => List.generate(paid.length, (index) => paid[index] ? monthly : 0).fold<int>(0, (sum, value) => sum + value);
  int get remaining => (amount - paidAmount).clamp(0, amount).toInt();

  LoanModel copyWith({List<bool>? paid}) => LoanModel(id: id, content: content, bank: bank, amount: amount, installments: installments, monthly: monthly, note: note, paid: paid ?? this.paid);

  Map<String, dynamic> toMap() => {'id': id, 'content': content, 'bank': bank.name, 'amount': amount, 'installments': installments, 'monthly': monthly, 'note': note, 'paid': paid.map((value) => value ? '1' : '0').join(',')};

  factory LoanModel.fromMap(Map<String, dynamic> map) => LoanModel(id: map['id'] as String?, content: map['content'] as String, bank: BorrowBank.values.byName(map['bank'] as String), amount: map['amount'] as int, installments: map['installments'] as int, monthly: map['monthly'] as int, note: (map['note'] as String?) ?? '', paid: (map['paid'] as String).isEmpty ? <bool>[] : (map['paid'] as String).split(',').map((value) => value == '1').toList());
}

class LendingModel {
  final String? id;
  final String content;
  final int amount;
  final DateTime startDate;
  final LoanType type;
  final LendingTarget target;
  final int paid;
  final String note;

  LendingModel({this.id, required this.content, required this.amount, required this.startDate, required this.type, required this.target, required this.paid, required this.note});

  int get remaining => (amount - paid).clamp(0, amount).toInt();

  Map<String, dynamic> toMap() => {'id': id, 'content': content, 'amount': amount, 'start_date': startDate.toIso8601String(), 'type': type.name, 'target': target.name, 'paid': paid, 'note': note};

  factory LendingModel.fromMap(Map<String, dynamic> map) => LendingModel(id: map['id'] as String?, content: map['content'] as String, amount: map['amount'] as int, startDate: DateTime.parse(map['start_date'] as String), type: LoanType.values.byName(map['type'] as String), target: LendingTarget.values.byName(map['target'] as String), paid: map['paid'] as int, note: (map['note'] as String?) ?? '');
}
