import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // ─── Colors ─────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0C0C0C);
  static const _green = Color(0xFF00FF41);
  static const _dimGreen = Color(0xFF008F11);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF2A2A2A);
  static const _textMuted = Color(0xFF666666);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthController>().token;
    if (token == null) return;

    final result = await context.read<ProductController>().addProduct(
          token,
          _nameCtrl.text.trim(),
          int.parse(_priceCtrl.text.trim()),
          _descCtrl.text.trim(),
        );

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      _showErrorSnack(result['message'] ?? 'Gagal menambahkan produk.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF111111),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '// SUCCESS',
                style: _mono(color: _green, size: 13, bold: true),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '> Produk berhasil ditambahkan',
                style: _mono(color: const Color(0xFFCCCCCC), size: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(true); // return to list
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                  color: _green,
                  child: Text(
                    '[OK]',
                    style: _mono(color: Colors.black, size: 13, bold: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A0000),
        content: Text(
          '! $msg',
          style: _mono(color: Colors.redAccent, size: 12),
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '> MASUKKAN DATA PRODUK:',
                        style: _mono(color: _dimGreen, size: 12),
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        label: 'NAMA PRODUK',
                        hint: '',
                        controller: _nameCtrl,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Nama produk tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'HARGA (IDR)',
                        hint: '',
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          if (int.tryParse(v) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'DESKRIPSI',
                        hint: '',
                        controller: _descCtrl,
                        maxLines: 4,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Deskripsi tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: _border)),
              child: Text('[BACK]', style: _mono(color: _textMuted, size: 11)),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '// ADD PRODUCT',
            style: _mono(color: _green, size: 13, bold: true),
          ),
        ],
      ),
    );
  }

  // ─── Field ───────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _mono(color: _textMuted, size: 11)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: _mono(color: _green, size: 13),
          cursorColor: _green,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _mono(color: const Color(0xFF333333), size: 12),
            prefixText: '> ',
            prefixStyle: _mono(color: _dimGreen, size: 13),
            filled: true,
            fillColor: _surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: _border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: _green, width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            errorStyle: _mono(color: Colors.redAccent, size: 10),
          ),
        ),
      ],
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Consumer<ProductController>(
      builder: (_, ctrl, __) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: ctrl.isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.black,
              disabledBackgroundColor: _dimGreen,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              elevation: 0,
            ),
            child: ctrl.isSubmitting
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
                        'MENYIMPAN...',
                        style: _mono(color: Colors.black, size: 13, bold: true),
                      ),
                    ],
                  )
                : Text(
                    '[SIMPAN PRODUK]',
                    style: _mono(color: Colors.black, size: 14, bold: true),
                  ),
          ),
        );
      },
    );
  }

  // ─── Helper ─────────────────────────────────────────────────────────────
  TextStyle _mono({required Color color, double size = 12, bool bold = false}) {
    return GoogleFonts.robotoMono(
      color: color,
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
  }
}