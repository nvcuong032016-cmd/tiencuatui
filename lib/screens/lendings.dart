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
        appBar: AppBar(title: const Text('Cho vay & tiết kiệm')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAppSheet<void>(context, const LendingForm()).then((_) => load()),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Thêm khoản'),
        ),
        body: data.isEmpty
            ? const Center(child: Text('Chưa có khoản cho vay/tiết kiệm'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final item = data[index];
                  return PremiumCard(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
                        child: Text(item.type == LoanType.savings ? '🏦' : '👤', style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.content, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          Text('${item.target == LendingTarget.individual ? 'Cá nhân' : 'Tổ chức'} • ${DateFormat('dd/MM/yyyy').format(item.startDate)}', style: const TextStyle(color: Colors.white54)),
                          const SizedBox(height: 8),
                          Text('Còn lại ${money(item.remaining)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('Đã trả ${money(item.paid)}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                        ]),
                      ),
                      IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () async { await AppDb.instance.delete('lendings', item.id!); await load(); }),
                    ]),
                  );
                },
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
  final remaining = TextEditingController(text: '0');
  LoanType type = LoanType.lending;
  LendingTarget target = LendingTarget.individual;
  DateTime date = DateTime.now();

  Widget field(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool currency = false, int maxLines = 1, bool required = true, bool readOnly = false, ValueChanged<String>? onChanged}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onChanged: onChanged,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          inputFormatters: currency ? [MoneyInputFormatter()] : null,
          decoration: InputDecoration(labelText: label, suffixText: currency ? 'đ' : null),
          validator: required ? (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập $label' : null : null,
        ),
      );

  void _updateRemaining([String? _]) {
    final value = (parseMoney(amount.text) - parseMoney(paid.text)).clamp(0, parseMoney(amount.text)).toInt();
    remaining.text = money(value);
  }

  @override
  void dispose() {
    content.dispose(); amount.dispose(); paid.dispose(); note.dispose(); remaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormSheet(
        title: 'Thêm khoản',
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              field('Nội dung', content),
              field('Số tiền', amount, keyboardType: TextInputType.number, currency: true, onChanged: _updateRemaining),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<LoanType>(
                    initialValue: type,
                    items: const [
                      DropdownMenuItem(value: LoanType.lending, child: Text('Cho vay')),
                      DropdownMenuItem(value: LoanType.savings, child: Text('Tiết kiệm')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => type = value); },
                    decoration: const InputDecoration(labelText: 'Loại'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<LendingTarget>(
                    initialValue: target,
                    items: const [
                      DropdownMenuItem(value: LendingTarget.individual, child: Text('Cá nhân')),
                      DropdownMenuItem(value: LendingTarget.organization, child: Text('Tổ chức')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => target = value); },
                    decoration: const InputDecoration(labelText: 'Đối tượng'),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final selected = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: date);
                  if (selected != null && mounted) setState(() => date = selected);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ngày bắt đầu', suffixIcon: Icon(Icons.calendar_month_rounded)),
                  child: Text(DateFormat('dd/MM/yyyy').format(date)),
                ),
              ),
              const SizedBox(height: 12),
              field('Đã trả', paid, keyboardType: TextInputType.number, currency: true, onChanged: _updateRemaining),
              field('Còn lại', remaining, readOnly: true, required: false),
              field('Ghi chú (không bắt buộc)', note, maxLines: 3, required: false),
              FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Lưu khoản'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final amountValue = parseMoney(amount.text);
                  final paidValue = parseMoney(paid.text);
                  if (amountValue <= 0 || paidValue < 0) return;
                  await AppDb.instance.saveLending(LendingModel(content: content.text.trim(), amount: amountValue, startDate: date, type: type, target: target, paid: paidValue, note: note.text.trim()));
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ]),
          ),
        ),
      );
}
