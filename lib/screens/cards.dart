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
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const CardForm(),
          ).then((_) => load()),
          child: const Icon(Icons.add),
        ),
        body: data.isEmpty
            ? const Center(child: Text('Chưa có thẻ tín dụng'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: data
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PremiumCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.credit_card),
                            ),
                            title: Text('${card.bank} • ${cardTypeLabel(card.type)}'),
                            subtitle: Text(
                              '•••• ${card.number.length >= 4 ? card.number.substring(card.number.length - 4) : card.number}\nMiễn lãi ${card.graceDays} ngày • Hạn mức ${money(card.limit)}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await AppDb.instance.delete('cards', card.id!);
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

class CardForm extends StatefulWidget {
  const CardForm({super.key});
  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final formKey = GlobalKey<FormState>();
  final number = TextEditingController();
  final bank = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();
  final grace = TextEditingController(text: '45');
  final statement = TextEditingController(text: '15');
  final payment = TextEditingController(text: '25');
  final limit = TextEditingController();
  CardType type = CardType.visa;

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
    number.dispose(); bank.dispose(); expiry.dispose(); cvv.dispose(); grace.dispose(); statement.dispose(); payment.dispose(); limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Thêm thẻ tín dụng'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  field('Số thẻ', number, keyboardType: TextInputType.number),
                  field('Ngân hàng', bank),
                  DropdownButtonFormField<CardType>(
                    initialValue: type,
                    items: CardType.values.map((value) => DropdownMenuItem(value: value, child: Text(cardTypeLabel(value)))).toList(),
                    onChanged: (value) { if (value != null) setState(() => type = value); },
                    decoration: const InputDecoration(labelText: 'Loại thẻ'),
                  ),
                  const SizedBox(height: 10),
                  field('Ngày hết hạn', expiry),
                  field('Mã CCV', cvv, keyboardType: TextInputType.number),
                  field('Số ngày miễn lãi', grace, keyboardType: TextInputType.number),
                  field('Ngày sao kê', statement, keyboardType: TextInputType.number),
                  field('Ngày thanh toán', payment, keyboardType: TextInputType.number),
                  field('Hạn mức', limit, keyboardType: TextInputType.number),
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
              final cardLimit = int.tryParse(limit.text) ?? 0;
              final graceDays = int.tryParse(grace.text) ?? 0;
              final statementDay = int.tryParse(statement.text) ?? 0;
              final paymentDay = int.tryParse(payment.text) ?? 0;
              if (cardLimit <= 0 || graceDays <= 0 || statementDay <= 0 || paymentDay <= 0) return;
              await AppDb.instance.saveCard(CreditCardModel(number: number.text.trim(), bank: bank.text.trim(), type: type, expiry: expiry.text.trim(), cvv: cvv.text.trim(), graceDays: graceDays, statementDay: statementDay, paymentDay: paymentDay, limit: cardLimit));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
}
