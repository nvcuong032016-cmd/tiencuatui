import 'package:flutter/material.dart';
import '../db/app_db.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});
  @override
  State<LoansScreen> createState() => _LoansState();
}

class _LoansState extends State<LoansScreen> {
  List<LoanModel> data = [];
  Future<void> load() async {
    final value = await AppDb.instance.loans();
    if (mounted) setState(() => data = value);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> _openInstallments(LoanModel loan) async {
    final paid = List<bool>.from(loan.paid);
    await showAppSheet<void>(
      context,
      StatefulBuilder(
        builder: (context, setDialogState) => FormSheet(
          title: loan.content,
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                itemCount: loan.installments,
                itemBuilder: (_, index) => CheckboxListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  value: index < paid.length ? paid[index] : false,
                  title: Text('Kỳ ${(index + 1).toString().padLeft(2, '0')}'),
                  subtitle: Text(money(loan.monthly)),
                  onChanged: (value) {
                    while (paid.length < loan.installments) { paid.add(false); }
                    setDialogState(() => paid[index] = value ?? false);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () async {
                  await AppDb.instance.saveLoan(loan.copyWith(paid: paid));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Lưu kỳ đã trả'),
              ),
            ),
          ]),
        ),
      ),
    );
    await load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Khoản vay')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAppSheet<void>(context, const LoanForm()).then((_) => load()),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Thêm khoản vay'),
        ),
        body: data.isEmpty
            ? const Center(child: Text('Chưa có khoản vay'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 84),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final loan = data[index];
                  final progress = loan.amount == 0 ? 0.0 : (loan.paidAmount / loan.amount).clamp(0.0, 1.0);
                  return PremiumCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(loan.content, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                        IconButton(onPressed: () async { await AppDb.instance.delete('loans', loan.id!); await load(); }, icon: const Icon(Icons.delete_outline_rounded)),
                      ]),
                      Text('${bankLabel(loan.bank)} • ${loan.installments} kỳ', style: const TextStyle(color: Colors.white54)),
                      const SizedBox(height: 14),
                      ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress, minHeight: 8)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: _stat('Đã trả', money(loan.paidAmount))),
                        const SizedBox(width: 8),
                        Expanded(child: _stat('Còn lại', money(loan.remaining))),
                      ]),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _openInstallments(loan), icon: const Icon(Icons.checklist_rounded), label: const Text('Các kỳ trả góp'))),
                    ]),
                  );
                },
              ),
      );

  Widget _stat(String label, String value) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]),
      );
}

class LoanForm extends StatefulWidget {
  const LoanForm({super.key});
  @override
  State<LoanForm> createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final formKey = GlobalKey<FormState>();
  final content = TextEditingController();
  final amount = TextEditingController();
  final monthly = TextEditingController();
  int installments = 12;
  final note = TextEditingController();
  BorrowBank bank = BorrowBank.sacombank;

  Widget field(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool currency = false, int maxLines = 1, bool required = true, ValueChanged<String>? onChanged}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          inputFormatters: currency ? [MoneyInputFormatter()] : null,
          decoration: InputDecoration(labelText: label, suffixText: currency ? 'đ' : null),
          validator: required ? (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập $label' : null : null,
        ),
      );

  void _calculateMonthly([String? _]) {
    final loanAmount = parseMoney(amount.text);
    monthly.text = loanAmount > 0 ? money((loanAmount / installments).round()) : '';
  }

  @override
  void dispose() {
    content.dispose(); amount.dispose(); monthly.dispose(); note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormSheet(
        title: 'Thêm khoản vay',
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              field('Nội dung vay', content),
              DropdownButtonFormField<BorrowBank>(
                initialValue: bank,
                items: BorrowBank.values.map((value) => DropdownMenuItem(value: value, child: Text(bankLabel(value)))).toList(),
                onChanged: (value) { if (value != null) setState(() => bank = value); },
                decoration: const InputDecoration(labelText: 'Ngân hàng'),
              ),
              const SizedBox(height: 10),
              field('Số tiền vay', amount, keyboardType: TextInputType.number, currency: true, onChanged: _calculateMonthly),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: installments,
                    items: const [6, 12, 24].map((value) => DropdownMenuItem(value: value, child: Text('$value kỳ'))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => installments = value);
                        _calculateMonthly();
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Số kỳ'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: field('Trả mỗi tháng', monthly, keyboardType: TextInputType.number, currency: true)),
              ]),
              const SizedBox(height: 10),
              field('Ghi chú (không bắt buộc)', note, maxLines: 3, required: false),
              FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Lưu khoản vay'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final count = installments;
                  final loanAmount = parseMoney(amount.text);
                  final monthlyAmount = parseMoney(monthly.text);
                  if (count <= 0 || loanAmount <= 0 || monthlyAmount <= 0) return;
                  await AppDb.instance.saveLoan(LoanModel(content: content.text.trim(), bank: bank, amount: loanAmount, installments: count, monthly: monthlyAmount, note: note.text.trim(), paid: List<bool>.filled(count, false)));
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ]),
          ),
        ),
      );
}
