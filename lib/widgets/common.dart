import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final moneyFmt = NumberFormat('#,###', 'vi_VN');
String money(int value) => '${moneyFmt.format(value)} đ';
int parseMoney(String value) => int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = moneyFmt.format(int.parse(digits));
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

Future<T?> showAppSheet<T>(BuildContext context, Widget child) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .88),
          decoration: const BoxDecoration(
            color: Color(0xFF1A2129),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: child,
        ),
      ),
    );

class FormSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const FormSheet({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 6),
            child: Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
          ),
          Flexible(child: child),
        ],
      );
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const PremiumCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF252D37), Color(0xFF1C232B)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .10)),
          boxShadow: const [BoxShadow(blurRadius: 14, offset: Offset(0, 5), color: Colors.black26)],
        ),
        child: child,
      );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String icon;
  const SectionTitle(this.icon, this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFE0C47A).withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0)),
        ]),
      );
}
