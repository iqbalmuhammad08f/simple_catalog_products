import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import 'add_product_page.dart';
import 'submit_page.dart';
import 'login_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  
  static const _bg = Color(0xFF0C0C0C);
  static const _green = Color(0xFF00FF41);
  static const _dimGreen = Color(0xFF008F11);
  static const _amber = Color(0xFFFFB000);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF2A2A2A);
  static const _textMuted = Color(0xFF666666);
  static const _textLight = Color(0xFFCCCCCC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    final token = context.read<AuthController>().token;
    if (token != null) {
      await context.read<ProductController>().fetchProducts(token);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _buildConfirmDialog(),
    );
    if (confirm == true && mounted) {
      await context.read<AuthController>().logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _goToAddProduct() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddProductPage()),
    );
    if (result == true && mounted) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            _buildSubHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // Top Bar
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '// PRODUCT CATALOG',
              style: _mono(color: _green, size: 13, bold: true),
              overflow:
                  TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubmitPage()),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _amber.withOpacity(0.6)),
                  ),
                  child: Text(
                    '[SUBMIT]',
                    style: _mono(color: _amber, size: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    '[LOGOUT]',
                    style: _mono(color: Colors.redAccent, size: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sub Header
  Widget _buildSubHeader() {
    return Consumer<ProductController>(
      builder: (_, ctrl, __) {
        final count = ctrl.products.length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Text('> ', style: _mono(color: _dimGreen, size: 12)),
              Text(
                '$count PRODUK DITEMUKAN',
                style: _mono(color: _textMuted, size: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  // Body
  Widget _buildBody() {
    return Consumer<ProductController>(
      builder: (_, ctrl, __) {
        if (ctrl.isLoading) return _buildLoading();
        if (ctrl.errorMessage != null) return _buildError(ctrl.errorMessage!);
        if (ctrl.products.isEmpty) return _buildEmpty();
        return _buildList(ctrl.products);
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _green, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            '> MEMUAT DATA...',
            style: _mono(color: _dimGreen, size: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
            const SizedBox(height: 12),
            Text(
              '! ERROR: $msg',
              style: _mono(color: Colors.redAccent, size: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _retryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            '> Belum ada produk.\n> Tekan [+] untuk menambahkan.',
            style: _mono(color: _textMuted, size: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<ProductModel> products) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: _green,
      backgroundColor: _surface,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _buildProductCard(products[i], i + 1),
      ),
    );
  }

  Widget _buildProductCard(ProductModel p, int index) {
    final idx = index.toString().padLeft(3, '0');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$idx',
                style: _mono(color: _textMuted, size: 11),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  p.name,
                  style: _mono(color: _green, size: 13, bold: true),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: _border, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('PRICE  : ', style: _mono(color: _textMuted, size: 11)),
              Text(
                p.formattedPrice,
                style: _mono(color: _green, size: 12, bold: true),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DESC   : ', style: _mono(color: _textMuted, size: 11)),
              Expanded(
                child: Text(
                  p.description,
                  style: _mono(color: _textLight, size: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (p.createdAt.isNotEmpty)
            Row(
              children: [
                Text('CREATED: ', style: _mono(color: _textMuted, size: 10)),
                Text(
                  p.createdAt.length > 16
                      ? p.createdAt.substring(0, 16)
                      : p.createdAt,
                  style: _mono(color: _textMuted, size: 10),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // FAB 
  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _goToAddProduct,
      backgroundColor: _green,
      foregroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: const Icon(Icons.add),
    );
  }

  // Retry Button 
  Widget _retryButton() {
    return GestureDetector(
      onTap: _loadProducts,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: _green)),
        child: Text('[ RETRY ]', style: _mono(color: _green, size: 12)),
      ),
    );
  }

  // Confirm Logout Dialog 
  Widget _buildConfirmDialog() {
    return Dialog(
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// KONFIRMASI LOGOUT',
                style: _mono(color: _green, size: 13, bold: true)),
            const SizedBox(height: 12),
            Text(
              '> Apakah Anda yakin ingin keluar dari sistem?',
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
                      child: Text('[BATAL]',
                          style: _mono(color: _textMuted, size: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: Colors.redAccent,
                      alignment: Alignment.center,
                      child: Text(
                        '[LOGOUT]',
                        style: _mono(color: Colors.white, size: 12, bold: true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper 
  TextStyle _mono({required Color color, double size = 12, bool bold = false}) {
    return GoogleFonts.robotoMono(
      color: color,
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
  }
}
