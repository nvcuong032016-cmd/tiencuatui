import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';

class AppDb {
  static final AppDb instance = AppDb._();
  AppDb._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'tien_cua_tui.db'),
      version: 1,
      onCreate: (database, version) async {
        await database.execute('CREATE TABLE cards(id INTEGER PRIMARY KEY AUTOINCREMENT, number TEXT, bank TEXT, type TEXT, expiry TEXT, cvv TEXT, grace_days INTEGER, statement_day INTEGER, payment_day INTEGER, credit_limit INTEGER)');
        await database.execute('CREATE TABLE loans(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, bank TEXT, amount INTEGER, installments INTEGER, monthly INTEGER, note TEXT, paid TEXT)');
        await database.execute('CREATE TABLE lendings(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, amount INTEGER, start_date TEXT, type TEXT, target TEXT, paid INTEGER, note TEXT)');
      },
    );
    return _db!;
  }

  Future<List<CreditCardModel>> cards() async =>
      (await (await db).query('cards', orderBy: 'grace_days ASC'))
          .map(CreditCardModel.fromMap)
          .toList();

  Future<List<LoanModel>> loans() async =>
      (await (await db).query('loans', orderBy: 'id DESC'))
          .map(LoanModel.fromMap)
          .toList();

  Future<List<LendingModel>> lendings() async =>
      (await (await db).query(
        'lendings',
        orderBy: "CASE WHEN target='individual' THEN 0 ELSE 1 END, id DESC",
      ))
          .map(LendingModel.fromMap)
          .toList();

  Future<void> saveCard(CreditCardModel item) async {
    final database = await db;
    item.id == null
        ? await database.insert('cards', item.toMap())
        : await database.update(
            'cards',
            item.toMap(),
            where: 'id=?',
            whereArgs: [item.id],
          );
  }

  Future<void> saveLoan(LoanModel item) async {
    final database = await db;
    item.id == null
        ? await database.insert('loans', item.toMap())
        : await database.update(
            'loans',
            item.toMap(),
            where: 'id=?',
            whereArgs: [item.id],
          );
  }

  Future<void> saveLending(LendingModel item) async {
    final database = await db;
    item.id == null
        ? await database.insert('lendings', item.toMap())
        : await database.update(
            'lendings',
            item.toMap(),
            where: 'id=?',
            whereArgs: [item.id],
          );
  }

  Future<void> delete(String table, int id) async {
    await (await db).delete(table, where: 'id=?', whereArgs: [id]);
  }
}
