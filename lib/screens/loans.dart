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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loan.content),
          content: SizedBox(
            width: 480,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: loan.installments,
              itemBuilder: (_, index) => CheckboxListTile(
                value: index < paid.length ? paid[index] : false,
                title: Text('Kỳ ${(index + 1).toString().padLeft(2, '0')}'),
                subtitle: Text(money(loan.monthly)),
                onChanged: (value) {
                  while (paid.length < loan.installments) {
                    paid.add(false);
                  }
                  setDialogState(() => paid[index] = value ?? false);
                },
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            FilledButton(
              onPressed: () async {
                await AppDb.instance.saveLoan(loan.copyWith(paid: paid));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Lưu kỳ đã trả'),
            ),
          ],
        ),
      ),
    );
    await load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Khoản vay')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog<void>(context: context, builder: (_) => const LoanForm()).then((_) => load()),
          child: const Icon(Icons.add),
        ),
        body: data.isEmpty
            ? const Center(child: Text('Chưa có khoản vay'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: data.map((loan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(loan.content, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                          IconButton(
                            onPressed: () async {
                              await AppDb.instance.delete('loans', loan.id!);
                              await load();
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ]),
                        Text('${bankLabel(loan.bank)} • ${loan.installments} kỳ • ${money(loan.monthly)}/tháng', style: const TextStyle(color: Colors.white60)),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: loan.amount == 0 ? 0 : (loan.paidAmount / loan.amount).clamp(0.0, 1.0)),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Đã trả ${money(loan.paidAmount)}'),
                          Text('Còn ${money(loan.remaining)}'),
                        ]),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(onPressed: () => _openInstallments(loan), icon: const Icon(Icons.checklist), label: const Text('Các kỳ trả góp')),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
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
  final installments = TextEditingController(text: '12');
  final monthly = TextEditingController();
  final note = TextEditingController();
  BorrowBank bank = BorrowBank.sacombank;

  Widget field(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label),
          validator: (value) => value == null || value.trim().isEmpty ? 'Nhập thông tin' : null,
        ),
      );

  @override
  void dispose() {
    content.dispose(); amount.dispose(); installments.dispose(); monthly.dispose(); note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Thêm khoản vay'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(children: [
                field('Nội dung vay', content),
                DropdownButtonFormField<BorrowBank>(
                  initialValue: bank,
                  items: BorrowBank.values.map((value) => DropdownMenuItem(value: value, child: Text(bankLabel(value)))).toList(),
                  onChanged: (value) { if (value != null) setState(() => bank = value); },
                  decoration: const InputDecoration(labelText: 'Ngân hàng'),
                ),
                const SizedBox(height: 10),
                field('Số tiền vay', amount, keyboardType: TextInputType.number),
                field('Số kỳ trả góp', installments, keyboardType: TextInputType.number),
                field('Số tiền trả hàng tháng', monthly, keyboardType: TextInputType.number),
                field('Ghi chú', note),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final count = int.tryParse(installments.text) ?? 0;
              final loanAmount = int.tryParse(amount.text) ?? 0;
              final monthlyAmount = int.tryParse(monthly.text) ?? 0;
              if (count <= 0 || loanAmount <= 0 || monthlyAmount <= 0) return;
              await AppDb.instance.saveLoan(LoanModel(content: content.text.trim(), bank: bank, amount: loanAmount, installments: count, monthly: monthlyAmount, note: note.text.trim(), paid: List<bool>.filled(count, false)));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
}
