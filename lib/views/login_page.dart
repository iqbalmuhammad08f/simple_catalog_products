import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'product_list_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController(text: '242410102036');
  final _passwordCtrl = TextEditingController(text: '242410102036');
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  late AnimationController _blinkController;

  // Colors
  static const _bg = Color(0xFF0C0C0C);
  static const _green = Color(0xFF00FF41);
  static const _dimGreen = Color(0xFF008F11);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF2A2A2A);
  static const _textMuted = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<AuthController>();
    final success = await ctrl.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ProductListPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildInputSection(),
                const SizedBox(height: 32),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildErrorSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// PRODUCT CATALOG',
          style: _monoStyle(color: _green, fontSize: 16, bold: true),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ─── Input Section ──────────────────────────────────────────────────────
  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildTextField(
          label: 'USERNAME',
          controller: _usernameCtrl,
          prefix: '> ',
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Username tidak boleh kosong' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'PASSWORD',
          controller: _passwordCtrl,
          prefix: '> ',
          obscure: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: _textMuted,
              size: 18,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Password tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String prefix = '',
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _monoStyle(color: _textMuted, fontSize: 11),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: _monoStyle(color: _green, fontSize: 14),
          cursorColor: _green,
          validator: validator,
          decoration: InputDecoration(
            prefixText: prefix,
            prefixStyle: _monoStyle(color: _dimGreen, fontSize: 14),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: _green, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            errorStyle: _monoStyle(color: Colors.redAccent, fontSize: 10),
          ),
        ),
      ],
    );
  }

  // ─── Login Button ────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return Consumer<AuthController>(
      builder: (_, ctrl, __) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: ctrl.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.black,
              disabledBackgroundColor: _dimGreen,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 0,
            ),
            child: ctrl.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'MEMPROSES...',
                        style: _monoStyle(
                          color: Colors.black,
                          fontSize: 13,
                          bold: true,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '[LOGIN]',
                    style: _monoStyle(
                      color: Colors.black,
                      fontSize: 14,
                      bold: true,
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ─── Error Section ──────────────────────────────────────────────────────
  Widget _buildErrorSection() {
    return Consumer<AuthController>(
      builder: (_, ctrl, __) {
        if (ctrl.errorMessage == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent),
            color: Colors.redAccent.withOpacity(0.08),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '! ${ctrl.errorMessage}',
                  style: _monoStyle(color: Colors.redAccent, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Helper ─────────────────────────────────────────────────────────────
  TextStyle _monoStyle({
    required Color color,
    double fontSize = 12,
    bool bold = false,
  }) {
    return GoogleFonts.robotoMono(
      color: color,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
  }
}
