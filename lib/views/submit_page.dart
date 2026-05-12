import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();

  bool _isSubmitted = false;
  Map<String, dynamic>? _submitResult;

  // ─── Colors ─────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0C0C0C);
  static const _green = Color(0xFF00FF41);
  static const _dimGreen = Color(0xFF008F11);
  static const _amber = Color(0xFFFFB000);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF2A2A2A);
  static const _textMuted = Color(0xFF666666);
  static const _textLight = Color(0xFFCCCCCC);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _githubCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Konfirmasi sebelum submit — tidak bisa diedit setelah submit
    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    final token = context.read<AuthController>().token;
    if (token == null) return;

    final result = await context.read<ProductController>().submitTugas(
          token,
          _nameCtrl.text.trim(),
          int.parse(_priceCtrl.text.trim()),
          _descCtrl.text.trim(),
          _githubCtrl.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _submitResult = result;
      _isSubmitted = result['success'] == true;
    });
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '// PERHATIAN ',
                style: _mono(color: _amber, size: 13, bold: true),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: _amber.withOpacity(0.4)),
                  color: _amber.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pastikan semua data sudah benar.\nLanjutkan submit?',
                style: _mono(color: _textLight, size: 12),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration:
                            BoxDecoration(border: Border.all(color: _border)),
                        alignment: Alignment.center,
                        child: Text(
                          '[BATAL]',
                          style: _mono(color: _textMuted, size: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: _green,
                        alignment: Alignment.center,
                        child: Text(
                          '[SUBMIT]',
                          style:
                              _mono(color: Colors.black, size: 12, bold: true),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              child: _isSubmitted
                  ? _buildSuccessScreen()
                  : _buildForm(),
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
            '// SUBMIT TUGAS',
            style: _mono(color: _amber, size: 13, bold: true),
          ),
        ],
      ),
    );
  }

  // ─── Form ────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '> LENGKAPI DATA PENGUMPULAN:',
              style: _mono(color: _dimGreen, size: 12),
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'NAMA PRODUK',
              hint: '',
              controller: _nameCtrl,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Nama produk tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 14),

            _buildField(
              label: 'HARGA (IDR)',
              hint: '',
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Harga tidak boleh kosong';
                if (int.tryParse(v) == null) return 'Masukkan angka yang valid';
                return null;
              },
            ),
            const SizedBox(height: 14),

            _buildField(
              label: 'DESKRIPSI',
              hint: '',
              controller: _descCtrl,
              maxLines: 3,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Deskripsi tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 14),

            _buildField(
              label: 'GITHUB REPOSITORY URL',
              hint: '',
              controller: _githubCtrl,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'GitHub URL tidak boleh kosong';
                }
                if (!v.startsWith('https://github.com/')) {
                  return 'URL harus diawali https://github.com/';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Error message
            Consumer<ProductController>(
              builder: (_, ctrl, __) {
                if (_submitResult != null &&
                    _submitResult!['success'] == false) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
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
                              '! ${_submitResult!['message']}',
                              style:
                                  _mono(color: Colors.redAccent, size: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ─── Success Screen ──────────────────────────────────────────────────────
  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '// TUGAS TERSUBMIT ',
              style: _mono(color: _green, size: 13, bold: true),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface,
                border: Border.all(color: _green.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DETAIL SUBMISSION :',
                    style: _mono(color: _textMuted, size: 10),
                  ),
                  const SizedBox(height: 10),
                  _successRow('NAMA ', _nameCtrl.text),
                  _successRow('HARGA', 'Rp ${_priceCtrl.text}'),
                  _successRow('DESC ', _descCtrl.text),
                  _successRow('REPO ', _githubCtrl.text),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: _dimGreen.withOpacity(0.4)),
                color: _dimGreen.withOpacity(0.05),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: _green)),
                child: Text(
                  '[KEMBALI KE LIST]',
                  style: _mono(color: _green, size: 12, bold: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$key: ', style: _mono(color: _textMuted, size: 11)),
          Expanded(
            child: Text(
              value,
              style: _mono(color: _green, size: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
              backgroundColor: _amber,
              foregroundColor: Colors.black,
              disabledBackgroundColor: _amber.withOpacity(0.4),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero),
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
                        'MENGUMPULKAN...',
                        style: _mono(color: Colors.black, size: 13, bold: true),
                      ),
                    ],
                  )
                : Text(
                    '[SUBMIT]',
                    style: _mono(color: Colors.black, size: 14, bold: true),
                  ),
          ),
        );
      },
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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

  // ─── Helper ─────────────────────────────────────────────────────────────
  TextStyle _mono({required Color color, double size = 12, bool bold = false}) {
    return GoogleFonts.robotoMono(
      color: color,
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
  }
}