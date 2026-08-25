import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/common.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool signUp = false;
  bool loading = false;
  String? message;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      setState(() => message = 'Nhập email và mật khẩu từ 6 ký tự');
      return;
    }
    setState(() { loading = true; message = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (signUp) {
        final result = await auth.signUp(email: email.text.trim(), password: password.text);
        if (result.session == null && mounted) {
          setState(() => message = 'Kiểm tra email để xác nhận tài khoản');
        }
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
      }
    } on AuthException catch (error) {
      final text = error.message.contains('SocketException') || error.message.contains('host lookup')
          ? 'Không thể kết nối máy chủ. Hãy kiểm tra Wi-Fi hoặc 4G rồi thử lại.'
          : error.message;
      if (mounted) setState(() => message = text);
    } catch (_) {
      if (mounted) setState(() => message = 'Không thể kết nối máy chủ. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: PremiumCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 42),
                    const SizedBox(height: 12),
                    Text(signUp ? 'Tạo tài khoản' : 'Đăng nhập', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 18),
                    TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 10),
                    TextField(controller: password, obscureText: true, onSubmitted: (_) => submit(), decoration: const InputDecoration(labelText: 'Mật khẩu')),
                    if (message != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(message!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.orangeAccent))),
                    const SizedBox(height: 14),
                    FilledButton(onPressed: loading ? null : submit, child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(signUp ? 'Đăng ký' : 'Đăng nhập')),
                    TextButton(onPressed: loading ? null : () => setState(() { signUp = !signUp; message = null; }), child: Text(signUp ? 'Đã có tài khoản? Đăng nhập' : 'Chưa có tài khoản? Đăng ký')),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
