import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/app_db.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'cards.dart';
import 'lendings.dart';
import 'loans.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CreditCardModel> cards = [];
  List<LoanModel> loans = [];
  List<LendingModel> lendings = [];
  bool loading = true;

  Future<void> load() async {
    if (mounted) setState(() => loading = true);
    final db = AppDb.instance;
    final cardsValue = await db.cards();
    final loansValue = await db.loans();
    final lendingsValue = await db.lendings();
    if (!mounted) return;
    setState(() {
      cards = cardsValue;
      loans = loansValue;
      lendings = lendingsValue;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  String lunar(DateTime date) => 'Lịch âm: đang cập nhật';

  @override
  Widget build(BuildContext context) {
    final totalLimit = cards.fold<int>(0, (sum, card) => sum + card.limit);
    final borrowed = loans.fold<int>(0, (sum, loan) => sum + loan.amount);
    final paid = loans.fold<int>(0, (sum, loan) => sum + loan.paidAmount);
    final remain = loans.fold<int>(0, (sum, loan) => sum + loan.remaining);
    final savings = lendings.where((item) => item.type == LoanType.savings).fold<int>(0, (sum, item) => sum + item.amount);
    final personalLending = lendings.where((item) => item.type == LoanType.lending && item.target == LendingTarget.individual).fold<int>(0, (sum, item) => sum + item.remaining);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('APP CỦA TUI', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Tiền tui, tui quản', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                  if (loading)
                    const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
                ],
              ),
              const SizedBox(height: 20),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(DateTime.now()), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(lunar(DateTime.now()), style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('💳', 'THẺ TÍN DỤNG'),
                    _row('', 'Số lượng thẻ', '${cards.length} thẻ'),
                    _row('', 'Tổng hạn mức', money(totalLimit)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsScreen())).then((_) => load()),
                        child: const Text('Quản lý →'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('📉', 'CÁC KHOẢN VAY'),
                    _row('', 'Số khoản vay', '${loans.length} khoản'),
                    _row('', 'Tổng tiền vay', money(borrowed)),
                    _row('', 'Đã trả', money(paid)),
                    _row('', 'Còn lại', money(remain)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen())).then((_) => load()),
                        child: const Text('Quản lý →'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('💰', 'CÁC KHOẢN CHO VAY'),
                    _row('🏦', 'Tiền tiết kiệm', money(savings)),
                    _row('👤', 'Cho vay cá nhân', money(personalLending)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingsScreen())).then((_) => load()),
                        child: const Text('Xem chi tiết →'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            if (icon.isNotEmpty) ...[Text(icon), const SizedBox(width: 8)],
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white60))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
