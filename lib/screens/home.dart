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
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 6),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Tiền của tui', style: TextStyle(letterSpacing: .1, fontWeight: FontWeight.w600, fontSize: 18)),
                      const SizedBox(height: 3),
                      Text('Tiền tui, tui quản', style: TextStyle(color: Colors.white.withValues(alpha: .48), fontSize: 13)),
                    ]),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: loading
                        ? const SizedBox(key: ValueKey('loading'), width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(key: const ValueKey('refresh'), onPressed: load, icon: const Icon(Icons.refresh_rounded)),
                  ),
                ]),
              ),
              PremiumCard(
                child: Row(children: [
                  Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.calendar_month_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(DateTime.now()), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(lunar(DateTime.now()), style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ])),
                ]),
              ),
              const SizedBox(height: 8),
              _dashboardCard(
                icon: '💳',
                title: 'Thẻ tín dụng',
                rows: [('Số lượng thẻ', '${cards.length} thẻ'), ('Tổng hạn mức', money(totalLimit))],
                label: 'Quản lý thẻ',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CardsScreen())).then((_) => load()),
              ),
              const SizedBox(height: 8),
              _dashboardCard(
                icon: '📉',
                title: 'Các khoản vay',
                rows: [('Số khoản vay', '${loans.length} khoản'), ('Tổng tiền vay', money(borrowed)), ('Đã trả', money(paid)), ('Còn lại', money(remain))],
                label: 'Quản lý khoản vay',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen())).then((_) => load()),
              ),
              const SizedBox(height: 8),
              _dashboardCard(
                icon: '💰',
                title: 'Cho vay & tiết kiệm',
                rows: [('Tiền tiết kiệm', money(savings)), ('Cho vay cá nhân', money(personalLending))],
                label: 'Xem chi tiết',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LendingsScreen())).then((_) => load()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({required String icon, required String title, required List<(String, String)> rows, required String label, required VoidCallback onTap}) => PremiumCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionTitle(icon, title),
          ...rows.map((row) => _row(row.$1, row.$2)),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(vertical: 6)),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(label),
            ),
          ),
        ]),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13))),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ]),
      );
}
