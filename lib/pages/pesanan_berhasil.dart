import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../services/session.dart';

class PesananBerhasilPage extends StatelessWidget {
  const PesananBerhasilPage({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryContainer = Color(0xFF1D4ED8);
  static const Color secondaryContainer = Color(0xFFDBEAFE);
  static const Color surfaceLow = Color(0xFFEFF6FF);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);

  // Cetak struk ke printer thermal
  static Future<void> _printReceipt(BuildContext context, _OrderData d) async {
    try {
      final doc = pw.Document();
      final fontRegular = pw.Font.helvetica();
      final fontBold = pw.Font.helveticaBold();

      doc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(
            58 * PdfPageFormat.mm,
            double.infinity,
            marginAll: 3 * PdfPageFormat.mm,
          ),
          build: (pw.Context ctx) {
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'WARKOP CAK KEBO',
                    style: pw.TextStyle(font: fontBold, fontSize: 13),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Jl. Raya Warkop No. 01, Surabaya',
                    style: pw.TextStyle(font: fontRegular, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Telp: 0812-3456-7890',
                    style: pw.TextStyle(font: fontRegular, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('No: ${d.code}', style: pw.TextStyle(font: fontBold, fontSize: 8)),
                      pw.Text('${d.orderType} • ${d.table}', style: pw.TextStyle(font: fontBold, fontSize: 8)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(d.whenStr, style: pw.TextStyle(font: fontRegular, fontSize: 7)),
                      pw.Text(
                        Session.name.isNotEmpty ? Session.name : 'Kasir POS',
                        style: pw.TextStyle(font: fontRegular, fontSize: 7),
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
                  ...d.items.map((item) {
                    final qty = item['qty'] ?? 1;
                    final name = (item['name'] ?? '-').toString();
                    final price = (item['price'] as num?)?.toInt() ?? 0;
                    final lineTotal = price * (qty as int);
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Text('${qty}x $name', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                          ),
                          pw.Text(d.rp.format(lineTotal), style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                        ],
                      ),
                    );
                  }),
                  pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Subtotal', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                      pw.Text(d.rp.format(d.subtotal), style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('PB1 Resto (10%)', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                      pw.Text(d.rp.format(d.tax), style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TOTAL', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      pw.Text(d.rp.format(d.total), style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Metode Bayar', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                      pw.Text('${d.payment} (Lunas)', style: pw.TextStyle(font: fontRegular, fontSize: 8)),
                    ],
                  ),
                  pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
                  pw.SizedBox(height: 4),
                  pw.BarcodeWidget(
                    data: d.code,
                    barcode: pw.Barcode.code128(),
                    width: 110,
                    height: 28,
                    drawText: false,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Terima Kasih Atas Kunjungan Anda!',
                    style: pw.TextStyle(font: fontBold, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'WiFi: ngebo / Password: warkopenak',
                    style: pw.TextStyle(font: fontRegular, fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Struk_${d.code}',
      );
    } catch (e) {
      debugPrint('Gagal mencetak struk: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka printer: $e')),
        );
      }
    }
  }

  // Kirim struk via WhatsApp
  static String _buildWhatsAppMessage(_OrderData d) {
    final buffer = StringBuffer();
    buffer.writeln('☕ *WARKOP CAK KEBO* ☕');
    buffer.writeln('📍 Jl. Raya Warkop No. 01, Surabaya');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📄 *STRUK PEMBAYARAN*');
    buffer.writeln('No. Pesanan : ${d.code}');
    buffer.writeln('Waktu       : ${d.whenStr}');
    buffer.writeln('Tipe / Meja : ${d.orderType} (${d.table})');
    buffer.writeln('Kasir       : ${Session.name.isNotEmpty ? Session.name : 'Kasir POS'}');
    buffer.writeln('Metode      : ${d.payment} (Lunas)');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    for (final item in d.items) {
      final qty = item['qty'] ?? 1;
      final name = item['name'] ?? '-';
      final price = (item['price'] as num?)?.toInt() ?? 0;
      buffer.writeln('$qty x $name  →  ${d.rp.format(price * (qty as int))}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Subtotal    : ${d.rp.format(d.subtotal)}');
    buffer.writeln('PB1 (10%)   : ${d.rp.format(d.tax)}');
    buffer.writeln('*TOTAL      : ${d.rp.format(d.total)}*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Terima kasih atas kunjungannya di Warkop Cak Kebo! 🙏');
    buffer.writeln('Selamat menikmati hidangan kami. ✨');
    return buffer.toString();
  }

  static Future<void> _sendWhatsApp(BuildContext context, _OrderData d, [String? phone]) async {
    final text = _buildWhatsAppMessage(d);
    final encodedText = Uri.encodeComponent(text);

    Uri uri;
    if (phone != null && phone.trim().isNotEmpty) {
      var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '62${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('62')) {
        cleanPhone = '62$cleanPhone';
      }
      uri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedText');
    } else {
      uri = Uri.parse('whatsapp://send?text=$encodedText');
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final fallbackUri = Uri.parse('https://api.whatsapp.com/send?text=$encodedText');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launch WA: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka WhatsApp: $e')),
        );
      }
    }
  }

  static void _showWhatsAppModal(BuildContext context, _OrderData d) {
    final phoneController = TextEditingController();
    final message = _buildWhatsAppMessage(d);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.send_to_mobile, color: Color(0xFF25D366), size: 22),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Kirim Struk WhatsApp',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nomor WhatsApp Pelanggan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Contoh: 08123456789 atau 62812...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.phone_android, size: 20, color: Color(0xFF2563EB)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pratinjau Pesan Struk',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxHeight: 130),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: AppTextStyles.mono(fontSize: 11, color: AppColors.secondaryDark),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.send, size: 18),
                    label: Text(
                      'Kirim ke Nomor Ini',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    onPressed: () {
                      final phone = phoneController.text.trim();
                      Navigator.pop(ctx);
                      _sendWhatsApp(context, d, phone);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      'Pilih Kontak WhatsApp Langsung',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _sendWhatsApp(context, d, null);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data pesanan dikirim dari kasir_page lewat Navigator arguments
    final d = _OrderData.from(context);
    final code = d.code;
    final orderType = d.orderType;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 16, 18),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, '/kasir');
                      }
                    },
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/images/logo_cak_kebo_transparent.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CAK KEBO',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            height: 1.1,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        Text(
                          'Pesanan Berhasil',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          orderType == 'Take Away' ? 'Take Away' : d.table,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Konten struk dan aksi
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.point_of_sale,
                                      color: primaryColor, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      orderType == 'Take Away'
                                          ? 'Kasir POS • Take Away • Konfirmasi'
                                          : 'Kasir POS • ${d.table} • Konfirmasi',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cloud_done,
                                      color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ref: $code',
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 800) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 7,
                                      child: _buildLeftColumn(context)),
                                  const SizedBox(width: 20),
                                  Expanded(
                                      flex: 5,
                                      child: _buildRightColumn(context)),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildLeftColumn(context),
                                  const SizedBox(height: 20),
                                  _buildRightColumn(context),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Material(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _printReceipt(context, d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.print_rounded, size: 20, color: primaryColor),
                      SizedBox(height: 2),
                      Text(
                        'Cetak Struk',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showWhatsAppModal(context, d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_to_mobile_rounded, size: 20, color: Color(0xFF25D366)),
                      SizedBox(height: 2),
                      Text(
                        'Kirim WA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(context, '/kasir');
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Pesanan Baru',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    final d = _OrderData.from(context);
    final code = d.code;
    final orderType = d.orderType;
    final payment = d.payment;
    final total = d.total;
    final whenStr = d.whenStr;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: secondaryContainer.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pembayaran Lunas & Terverifikasi',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pesanan Berhasil Dibuat!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1C30),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nomor Pesanan $code • ${orderType == 'Take Away' ? 'Take Away' : d.table} • $payment',
                textAlign: TextAlign.center,
                style: const TextStyle(color: onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL TRANSAKSI DITERIMA',
                      style: TextStyle(
                        color: onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Rp ',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          NumberFormat.decimalPattern('id_ID').format(total),
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 14, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              whenStr,
                              style: const TextStyle(
                                fontSize: 11,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '•',
                          style: TextStyle(color: onSurfaceVariant),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_2, size: 14, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Metode: $payment',
                              style: const TextStyle(
                                fontSize: 11,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tiket Otomatis Terkirim ke Bar & Dapur',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF0B1C30),
                            ),
                          ),
                          Text(
                            'Antrean Minuman & Makanan Aktif',
                            style: TextStyle(
                              fontSize: 11,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Terkirim',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    final d = _OrderData.from(context);
    final code = d.code;
    final orderType = d.orderType;
    final payment = d.payment;
    final subtotal = d.subtotal;
    final tax = d.tax;
    final total = d.total;
    final items = d.items;
    final rp = d.rp;
    int n(dynamic v) => _OrderData.n(v);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: primaryColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Rincian Nota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PAID $code',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _MetaRow(label: 'Tipe Pesanan', value: orderType),
                    const SizedBox(height: 6),
                    _MetaRow(label: 'Pembayaran', value: payment),
                    const SizedBox(height: 6),
                    _MetaRow(label: 'Kasir', value: Session.name.isNotEmpty ? Session.name : 'Kasir POS'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'ITEM DIPESAN',
                style: TextStyle(
                  color: onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ...items.expand<Widget>((it) => [
                    _ItemTile(
                      qty: '${it['qty']}x',
                      title: (it['name'] ?? '').toString(),
                      variant: (it['variant'] ?? '').toString(),
                      price: rp.format(n(it['price']) * n(it['qty'])),
                    ),
                    const SizedBox(height: 8),
                  ]),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'Subtotal Penjualan',
                      value: rp.format(subtotal),
                    ),
                    const SizedBox(height: 6),
                    _PriceRow(
                      label: 'PB1 / Pajak Resto (10%)',
                      value: rp.format(tax),
                    ),
                    const SizedBox(height: 6),
                    const _PriceRow(
                      label: 'Diskon Promosi',
                      value: '- Rp 0',
                      isDiscount: true,
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0B1C30),
                          ),
                        ),
                        Text(
                          rp.format(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF3F4850), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B1C30),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String qty;
  final String title;
  final String variant;
  final String price;

  const _ItemTile({
    required this.qty,
    required this.title,
    required this.variant,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: PesananBerhasilPage.surfaceLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PesananBerhasilPage.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              qty,
              style: const TextStyle(
                color: PesananBerhasilPage.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                Text(
                  variant,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3F4850),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF0B1C30),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF3F4850), fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? const Color(0xFF006194) : const Color(0xFF0B1C30),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Membaca data pesanan dari Navigator arguments (dikirim oleh kasir_page).
class _OrderData {
  final String code;
  final String orderType;
  final String table;
  final String payment;
  final String whenStr;
  final int subtotal;
  final int tax;
  final int total;
  final List<Map<String, dynamic>> items;
  final NumberFormat rp =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  _OrderData._({
    required this.code,
    required this.orderType,
    required this.table,
    required this.payment,
    required this.whenStr,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.items,
  });

  static int n(dynamic v) =>
      v is num ? v.round() : (double.tryParse(v?.toString() ?? '') ?? 0).round();

  factory _OrderData.from(BuildContext context) {
    final o = (ModalRoute.of(context)?.settings.arguments as Map?)
            ?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final when = DateTime.tryParse((o['created_at'] ?? '').toString())?.toLocal() ??
        DateTime.now();
    return _OrderData._(
      code: (o['code'] ?? '-').toString(),
      orderType: (o['order_type'] ?? '-').toString(),
      table: (o['table'] ?? o['terminal_id'] ?? 'Meja 01').toString(),
      payment: (o['payment_method'] ?? '-').toString(),
      whenStr: '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(when)} WIB',
      subtotal: n(o['subtotal']),
      tax: n(o['tax']),
      total: n(o['total']),
      items: ((o['items'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}
