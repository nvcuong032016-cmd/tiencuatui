import 'package:flutter/material.dart';
import '../db/app_db.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});
  @override
  State<CardsScreen> createState() => _CardsState();
}

class _CardsState extends State<CardsScreen> {
  List<CreditCardModel> data = [];
  Future<void> load() async {
    final value = await AppDb.instance.cards();
    if (mounted) setState(() => data = value);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Thẻ tín dụng')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAppSheet<void>(context, const CardForm()).then((_) => load()),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Thêm thẻ'),
        ),
        body: data.isEmpty
            ? const Center(child: Text('Chưa có thẻ tín dụng'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 84),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final card = data[index];
                  return PremiumCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.credit_card_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${card.bank} • ${cardTypeLabel(card.type)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 5),
                            Text('•••• ${card.number.length >= 4 ? card.number.substring(card.number.length - 4) : card.number}', style: const TextStyle(color: Colors.white60)),
                            const SizedBox(height: 4),
                            Text('Miễn lãi ${card.graceDays} ngày  •  ${money(card.limit)}', style: const TextStyle(color: Colors.white70)),
                          ]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () async {
                            await AppDb.instance.delete('cards', card.id!);
                            await load();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
}

class CardForm extends StatefulWidget {
  const CardForm({super.key});
  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final formKey = GlobalKey<FormState>();
  final number = TextEditingController();
  final expiry = TextEditingController();
  final statement = TextEditingController(text: '15');
  final payment = TextEditingController(text: '25');
  final limit = TextEditingController();
  CardType type = CardType.visa;
  BorrowBank bank = BorrowBank.sacombank;
  int graceDays = 45;

  Widget field(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool currency = false, String? hint}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          inputFormatters: currency ? [MoneyInputFormatter()] : null,
          decoration: InputDecoration(labelText: label, hintText: hint, suffixText: currency ? 'đ' : null),
          validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập $label' : null,
        ),
      );

  @override
  void dispose() {
    number.dispose(); expiry.dispose(); statement.dispose(); payment.dispose(); limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormSheet(
        title: 'Thêm thẻ tín dụng',
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              DropdownButtonFormField<BorrowBank>(
                initialValue: bank,
                items: BorrowBank.values.map((value) => DropdownMenuItem(value: value, child: Text(bankLabel(value)))).toList(),
                onChanged: (value) { if (value != null) setState(() => bank = value); },
                decoration: const InputDecoration(labelText: 'Ngân hàng'),
              ),
              const SizedBox(height: 10),
              field('Hạn mức', limit, keyboardType: TextInputType.number, currency: true, hint: '50.000.000'),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: DropdownButtonFormField<CardType>(
                    initialValue: type,
                    items: CardType.values.map((value) => DropdownMenuItem(value: value, child: Text(cardTypeLabel(value)))).toList(),
                    onChanged: (value) { if (value != null) setState(() => type = value); },
                    decoration: const InputDecoration(labelText: 'Loại thẻ'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: graceDays,
                    items: const [45, 55].map((value) => DropdownMenuItem(value: value, child: Text('$value ngày'))).toList(),
                    onChanged: (value) { if (value != null) setState(() => graceDays = value); },
                    decoration: const InputDecoration(labelText: 'Miễn lãi'),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              field('4 số cuối thẻ', number, keyboardType: TextInputType.number, hint: 'Ví dụ 1234'),
              field('Ngày hết hạn', expiry, hint: 'MM/YY'),
              Row(children: [
                Expanded(child: field('Ngày sao kê', statement, keyboardType: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: field('Ngày thanh toán', payment, keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 4),
              FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Lưu thẻ'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final cardLimit = parseMoney(limit.text);
                  final statementDay = int.tryParse(statement.text) ?? 0;
                  final paymentDay = int.tryParse(payment.text) ?? 0;
                  if (cardLimit <= 0 || number.text.trim().length != 4 || graceDays <= 0 || statementDay <= 0 || paymentDay <= 0) return;
                  await AppDb.instance.saveCard(CreditCardModel(number: number.text.trim(), bank: bankLabel(bank), type: type, expiry: expiry.text.trim(), graceDays: graceDays, statementDay: statementDay, paymentDay: paymentDay, limit: cardLimit));
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ]),
          ),
        ),
      );
}
