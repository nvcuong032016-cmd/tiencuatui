import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AppDb {
  static final AppDb instance = AppDb._();
  AppDb._();

  SupabaseClient get _client => Supabase.instance.client;
  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Bạn cần đăng nhập');
    return user.id;
  }

  Future<List<CreditCardModel>> cards() async {
    final rows = await _client.from('cards').select().order('grace_days');
    return rows.map((row) => CreditCardModel.fromMap(row)).toList();
  }

  Future<List<LoanModel>> loans() async {
    final rows = await _client.from('loans').select().order('created_at', ascending: false);
    return rows.map((row) => LoanModel.fromMap(row)).toList();
  }

  Future<List<LendingModel>> lendings() async {
    final rows = await _client.from('lendings').select().order('created_at', ascending: false);
    final items = rows.map((row) => LendingModel.fromMap(row)).toList();
    items.sort((a, b) {
      if (a.target == b.target) return 0;
      return a.target == LendingTarget.individual ? -1 : 1;
    });
    return items;
  }

  Future<void> saveCard(CreditCardModel item) => _save('cards', item.id, item.toMap());
  Future<void> saveLoan(LoanModel item) => _save('loans', item.id, item.toMap());
  Future<void> saveLending(LendingModel item) => _save('lendings', item.id, item.toMap());

  Future<void> _save(String table, String? id, Map<String, dynamic> values) async {
    final data = Map<String, dynamic>.from(values)
      ..remove('id')
      ..['user_id'] = _userId
      ..['updated_at'] = DateTime.now().toUtc().toIso8601String();
    if (id == null) {
      await _client.from(table).insert(data);
    } else {
      await _client.from(table).update(data).eq('id', id);
    }
  }

  Future<void> delete(String table, String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
