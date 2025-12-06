import 'dart:io'; // Import IO untuk File
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
import 'package:panganku_mobile/providers/cart_provider.dart';
import 'package:panganku_mobile/providers/checkout_provider.dart';
import 'package:panganku_mobile/ui/pages/main_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedTime = "";
  String _deliveryType = 'delivery';
  String _paymentMethod = 'tunai';

  // [BARU] Variable untuk menyimpan file bukti transfer
  File? _paymentProofFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
    }
    final now = DateTime.now().add(const Duration(hours: 1));
    _selectedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    Future.microtask(
      () => Provider.of<CheckoutProvider>(
        context,
        listen: false,
      ).fetchCheckoutData(),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // [BARU] Fungsi Pilih Gambar dari Galeri
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() {
        _paymentProofFile = File(image.path);
      });
    }
  }

  void _handleSubmit() async {
    // Validasi Dasar
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi data kontak")));
      return;
    }
    if (_deliveryType == 'delivery' && _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat pengiriman wajib diisi")),
      );
      return;
    }
    // Validasi Bukti Transfer (Jika bukan Tunai, Wajib Upload)
    // if (_paymentMethod != 'tunai' && _paymentProofFile == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Harap upload bukti transfer"),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    final checkoutProvider = Provider.of<CheckoutProvider>(
      context,
      listen: false,
    );
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final success = await checkoutProvider.processCheckout(
      name: _nameController.text,
      phone: _phoneController.text,
      deliveryType: _deliveryType,
      paymentMethod: _paymentMethod,
      address: _addressController.text,
      time: _selectedTime,
      paymentProof: _paymentProofFile, // Kirim file
    );

    if (!mounted) return;

    if (success) {
      _showSuccessDialog(cartProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            checkoutProvider.errorMessage ?? "Gagal memproses pesanan",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Pesanan Berhasil!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Terima kasih telah berbelanja. Cek status pesanan di menu Transaksi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cartProvider.fetchCart();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainPage()),
                    (r) => false,
                  );
                },
                child: const Text("OK, Mengerti"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final cart = Provider.of<CartProvider>(context);
    final checkoutData = Provider.of<CheckoutProvider>(context);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F4F6,
      ), // Background Abu lebih gelap dikit biar card stand out
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD 1: PENGIRIMAN
            _buildCard(
              title: "Metode Pengiriman",
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildTabOption(
                        "Diantar Kurir",
                        Icons.motorcycle,
                        'delivery',
                      ),
                      const SizedBox(width: 12),
                      _buildTabOption("Ambil Sendiri", Icons.store, 'pickup'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_deliveryType == 'delivery')
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        "Alamat Lengkap",
                        Icons.location_on_outlined,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📍 Lokasi Toko:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkoutData.storeAddress,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickTime,
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        "Jam Pengantaran",
                        Icons.access_time,
                      ),
                      child: Text(
                        _selectedTime,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CARD 2: KONTAK
            _buildCard(
              title: "Informasi Kontak",
              icon: Icons.person_outline,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration("Nama Penerima", Icons.person),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      "No WhatsApp",
                      Icons.phone_android,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CARD 3: PEMBAYARAN (PREMIUM UI)
            _buildCard(
              title: "Pembayaran",
              icon: Icons.payment,
              child: Column(
                children: [
                  // Opsi COD
                  _buildPaymentOption(
                    'tunai',
                    'Tunai (COD)',
                    'Bayar ditempat',
                    null,
                  ),

                  // Opsi Transfer Dinamis
                  ...checkoutData.paymentMethods.map((method) {
                    return Column(
                      children: [
                        const Divider(height: 1),
                        _buildPaymentOption(
                          method['name'],
                          method['name'],
                          "${method['account_number']} (a.n ${method['account_holder']})",
                          method['image_url'],
                        ),

                        // [FITUR BARU] Area Upload Bukti jika metode ini dipilih
                        if (_paymentMethod == method['name'])
                          Container(
                            margin: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.yellow[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.yellow[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.orange[800],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Silakan transfer ke rekening di atas, lalu upload buktinya di sini.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Tombol Upload / Preview
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: _paymentProofFile != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              _paymentProofFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 40,
                                                color: AppTheme.primary,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Upload Bukti Transfer",
                                                style: TextStyle(
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                if (_paymentProofFile != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Center(
                                      child: TextButton.icon(
                                        onPressed: () => setState(
                                          () => _paymentProofFile = null,
                                        ),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "Hapus Gambar",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // CARD 4: RINGKASAN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Tagihan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(cart.totalPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<CheckoutProvider>(
          builder: (context, checkout, child) {
            return ElevatedButton(
              onPressed: checkout.isLoading ? null : _handleSubmit,
              child: checkout.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text("Buat Pesanan Sekarang"),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Widget _buildTabOption(String title, IconData icon, String value) {
    final isSelected = _deliveryType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _deliveryType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String id,
    String title,
    String subtitle,
    String? imageUrl,
  ) {
    final isSelected = _paymentMethod == id;
    return InkWell(
      onTap: () => setState(() {
        _paymentMethod = id;
        _paymentProofFile = null; // Reset foto kalau ganti metode
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 35,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: imageUrl != null
                  ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain)
                  : const Icon(Icons.money, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
