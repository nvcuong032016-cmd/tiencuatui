import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final moneyFmt = NumberFormat('#,###', 'vi_VN');
String money(int value) => '${moneyFmt.format(value)} đ';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFF15181D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black45)],
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
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
}
