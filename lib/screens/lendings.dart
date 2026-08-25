import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/app_db.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class LendingsScreen extends StatefulWidget {
  const LendingsScreen({super.key});
  @override
  State<LendingsScreen> createState() => _LendingsState();
}

class _LendingsState extends State<LendingsScreen> {
  List<LendingModel> data = [];
  Future<void> load() async {
    final value = await AppDb.instance.lendings();
    if (mounted) setState(() => data = value);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Các khoản cho vay')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const LendingForm(),
          ).then((_) => load()),
          child: const Icon(Icons.add),
        ),
        body: data.isEmpty
            ? const Center(child: Text('Chưa có khoản cho vay/tiết kiệm'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: data
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PremiumCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Text(
                              item.type == LoanType.savings ? '🏦' : '👤',
                              style: const TextStyle(fontSize: 26),
                            ),
                            title: Text(item.content),
                            subtitle: Text(
                              '${item.target == LendingTarget.individual ? 'Cá nhân' : 'Tổ chức'} • ${DateFormat('dd/MM/yyyy').format(item.startDate)}\nĐã trả ${money(item.paid)} • Còn ${money(item.remaining)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await AppDb.instance.delete('lendings', item.id!);
                                await load();
                              },
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      );
}

class LendingForm extends StatefulWidget {
  const LendingForm({super.key});
  @override
  State<LendingForm> createState() => _LendingFormState();
}

class _LendingFormState extends State<LendingForm> {
  final formKey = GlobalKey<FormState>();
  final content = TextEditingController();
  final amount = TextEditingController();
  final paid = TextEditingController(text: '0');
  final note = TextEditingController();
  LoanType type = LoanType.lending;
  LendingTarget target = LendingTarget.individual;
  DateTime date = DateTime.now();

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
    content.dispose(); amount.dispose(); paid.dispose(); note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Thêm khoản'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  field('Nội dung', content),
                  field('Số tiền', amount, keyboardType: TextInputType.number),
                  DropdownButtonFormField<LoanType>(
                    initialValue: type,
                    items: const [
                      DropdownMenuItem(value: LoanType.lending, child: Text('Cho vay')),
                      DropdownMenuItem(value: LoanType.savings, child: Text('Tiết kiệm')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => type = value); },
                    decoration: const InputDecoration(labelText: 'Loại'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<LendingTarget>(
                    initialValue: target,
                    items: const [
                      DropdownMenuItem(value: LendingTarget.individual, child: Text('Cá nhân')),
                      DropdownMenuItem(value: LendingTarget.organization, child: Text('Tổ chức')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => target = value); },
                    decoration: const InputDecoration(labelText: 'Đối tượng'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(date)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final selected = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: date);
                      if (selected != null && mounted) setState(() => date = selected);
                    },
                  ),
                  field('Đã trả', paid, keyboardType: TextInputType.number),
                  field('Ghi chú', note),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amountValue = int.tryParse(amount.text) ?? 0;
              final paidValue = int.tryParse(paid.text) ?? 0;
              if (amountValue <= 0 || paidValue < 0) return;
              await AppDb.instance.saveLending(LendingModel(content: content.text.trim(), amount: amountValue, startDate: date, type: type, target: target, paid: paidValue, note: note.text.trim()));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
}
