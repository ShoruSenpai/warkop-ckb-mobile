import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  String _activeCategory = 'Semua';
  String _orderType = 'Dine In';
  String _paymentMethod = 'QRIS';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Color primary = const Color(0xFF2563EB);
  final Color primaryDark = const Color(0xFF1D4ED8);
  final Color primaryLight = const Color(0xFFDBEAFE);
  final Color secondary = const Color(0xFF64748B);
  final Color surface = const Color(0xFFF4F6FB);
  final Color surfaceWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF0F172A);
  final Color textSecondary = const Color(0xFF475569);
  final Color borderLight = const Color(0xFFE2E8F0);
  final Color successBg = const Color(0xFFDCFCE7);
  final Color successText = const Color(0xFF15803D);

  final List<String> _categories = [
    'Semua',
    'Kopi Susu',
    'Manual Brew',
    'Non-Kopi',
    'Camilan Tradisional',
    'Makanan Berat'
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'cat': 'Kopi Susu',
      'name': 'Kopi Susu Cak Kebo',
      'desc': 'Gula aren organik, double espresso',
      'price': 18000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuARybcadp9pYMQHJULLtF0871NifTwt1KSueZDE_gbnnaIFzKWeun-ksPIfMnBJiU7JfBvI2PVHHLzbxrCBwkliATgfRgqyPolB0sAemmbjbDaST9aSLDwEhGtxi0Y7Cke9U_pwhWZx9JvdQVdnN_GapDmRB5h_IrQD4LSmg6dmO6qnnJeoP5tqSjQh1Uf1o11LULqrEUOQshES8RR1bdPn3I4xG5f2QXEtcDRqv9ZUz-vTSn6PxIgfjQ',
      'tag': 'Favorit'
    },
    {
      'cat': 'Manual Brew',
      'name': 'Espresso Single',
      'desc': 'Arabica Gayo wash 30ml',
      'price': 15000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDaaCnJp_jl4wJMguixT2C0oEHKSxcYq0r-Huao-aYpCmZmyaSx1SFz1d9QrN2m2HlryQ3Ys0R2eVFH1X-RnwAe_kkHbpAvZ_7eCVWZhrNXsdP9D198BpZOKeFtSmDThI2lJUUeK8Hkx6VxVBRGLJ1RvB2zSPO3oWw2KtxO71BkJGU0s7jKFQlxoJOPZQQPD2XyTZRvQPEy_Fg2B6pZH38UBT-k5pq2mnvPn5Mz8JWRTqjTcFTZ5-3Bvg',
    },
    {
      'cat': 'Manual Brew',
      'name': 'Americano Dingin',
      'desc': 'Clean body, fruity notes',
      'price': 16000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuACU9VPBe25t4rbG5HD7MD4VIc-EHESgrVYRomYzRxUH4G8zwtKI2sQy0kobtwQ6xYhycuf_J0iDZE2OvY-nUyijfE7W201nJEAXMKTlcCeKYPZ0WyNxXJPPxPoOtvrH6G4jR8lf6yoofCFODIYwrUTMtT7bMVUG6IRtBplAX5tnVjc8RRCx0HxJ4E72dnyT50ImQspGp_0PQt0MxPFvZq9-LRCjw8Crpt47CwHw_q55141Npux5fC49A',
    },
    {
      'cat': 'Non-Kopi',
      'name': 'Matcha Latte',
      'desc': 'Uji matcha murni dengan oatmilk',
      'price': 26000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCnpi1EXgLfpIPOEQdbBOMduUZJfOn7_NWpMByE83_vlrNg3m-Gk8QLAvwMDzmPxaWUpUPOVy9Rhix5f_FmJUTS_O594-iuiCQOg8qSmU3lfww7rootD3cHNEm65SpSBCoznf3N8zJOU7INbtMuHMUBG49xAlFE9TN_dEzZGjVRM3YAx2vEIYCFpbzUUfFz1kS9fhaaBLkRzfQEFPJaqwI3Vtsgnm-3n26NOVBP-gGwi2e1r03u-AKXAw',
      'tag': 'Artisan'
    },
    {
      'cat': 'Camilan Tradisional',
      'name': 'Pisang Goreng Wijen',
      'desc': 'Pisang kepok madu, renyah wangi',
      'price': 16000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD8Cux6ikayaCbNXUstL6MLPbuBqkSoVxxLO8vtzWkBj-UotkPdW0ctLjPjN3lC8LzSqZnj9yaMJ5Ivz6VxUJWB3-AquCCrfRwdW3yFz5W7BKlD9dkvVvWNE705IIxQd2pnsA57CVM2-WUq4IY14Hd8PsUbvj4S7K1PLHeiM7AUNX0n4jgMACj0czPW8Oc6irEW08UwH80yxLiPE8yo6W8SO2KiXoZLSAZXfciP3jMOVpu6BKlQ_UBDrw',
    },
    {
      'cat': 'Makanan Berat',
      'name': 'Nasi Goreng Kampung',
      'desc': 'Telur mata sapi, acar segar',
      'price': 28000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC1h55M00RisBoFXM7SiZuNbZU-TFfVNorP_7c_66_IJiqCYVY9kMfs_Jiq5NHChRW26tZbrYOrsD29cQEjCiFWtScsJsUOLrV6Wbis-vjfEqjGsvNo1i446x0VzTZu8Du4ccPMoQ5MGogmnRGdNb27wmM1FrsX2f79L44Vl-ZoHtIF3nlCDmlKFcpoVvPRQCgpvrFuM_J8hpsth2_aCdRYxqdwh4TnJUCjlTJIyp0NytFtmv_W5tGltQ',
    },
  ];

  final List<Map<String, dynamic>> _cart = [
    {
      'name': 'Kopi Susu Cak Kebo',
      'variant': 'Normal Ice, Less Sugar',
      'price': 18000,
      'qty': 1
    },
    {
      'name': 'Pisang Goreng Wijen',
      'variant': 'Topping Cokelat Keju',
      'price': 16000,
      'qty': 2
    },
    {
      'name': 'Matcha Latte',
      'variant': 'Substitusi Oatmilk (+Rp 6.000)',
      'price': 26000,
      'qty': 1
    },
  ];

  String _formatRp(int number) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(number);
  }

  int _getItemQty(String name) {
    for (var item in _cart) {
      if (item['name'] == name) {
        return item['qty'] as int;
      }
    }
    return 0;
  }

  void _addItem(Map<String, dynamic> product) {
    setState(() {
      int index = _cart.indexWhere((item) => item['name'] == product['name']);
      if (index >= 0) {
        _cart[index]['qty'] = (_cart[index]['qty'] as int) + 1;
      } else {
        _cart.add({
          'name': product['name'],
          'variant': product['desc'],
          'price': product['price'],
          'qty': 1,
        });
      }
    });
  }

  void _removeItem(String name) {
    setState(() {
      int index = _cart.indexWhere((item) => item['name'] == name);
      if (index >= 0) {
        int currentQty = _cart[index]['qty'] as int;
        if (currentQty > 1) {
          _cart[index]['qty'] = currentQty - 1;
        } else {
          _cart.removeAt(index);
        }
      }
    });
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext sheetContext, StateSetter setModalState) {
            int subtotal = _cart.fold(
                0, (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));
            int tax = (subtotal * 0.10).round();
            int total = subtotal + tax;
            int totalItems =
                _cart.fold(0, (sum, item) => sum + (item['qty'] as int));

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: borderLight,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rincian Pesanan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                '$totalItems Item Terpilih • Meja #04',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: surface,
                              foregroundColor: textSecondary,
                            ),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: ['Dine In', 'Take Away'].map((type) {
                          bool isActive = _orderType == type;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _orderType = type);
                                setModalState(() {});
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: type == 'Dine In' ? 8 : 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive ? primary : surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isActive ? primary : borderLight,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  type,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isActive ? Colors.white : textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      if (_cart.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              'Keranjang masih kosong',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cart.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: borderLight, width: 0.8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatRp(item['price']),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: borderLight, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _removeItem(item['name']);
                                            setModalState(() {});
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.remove,
                                                size: 15, color: Colors.black87),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            item['qty'].toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _addItem(item);
                                            setModalState(() {});
                                          },
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add,
                                                size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Metode Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['QRIS', 'Tunai', 'Debit / EDC'].map((method) {
                          bool isActive = _paymentMethod == method;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _paymentMethod = method);
                                setModalState(() {});
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    right: method != 'Debit / EDC' ? 6 : 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive ? primaryLight : surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isActive ? primary : borderLight,
                                    width: 1.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  method,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? primary : textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderLight, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                                Text(
                                  _formatRp(subtotal),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pajak Resto (PB1 10%)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                                Text(
                                  _formatRp(tax),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: borderLight, height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Tagihan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  _formatRp(total),
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _cart.isEmpty
                            ? null
                            : () {
                                Navigator.pop(sheetContext);
                                Navigator.pushNamed(context, '/pesanan_berhasil');
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Konfirmasi Pembayaran (${_formatRp(total)})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int subtotal = _cart.fold(
        0, (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));
    int tax = (subtotal * 0.10).round();
    int total = subtotal + tax;
    int totalCartItems =
        _cart.fold(0, (sum, item) => sum + (item['qty'] as int));

    final filteredProducts = _products.where((p) {
      final matchCat =
          _activeCategory == 'Semua' || p['cat'] == _activeCategory;
      final matchQuery = _searchQuery.isEmpty ||
          p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                  ),
                  Container(
                    width: 48,
                    height: 48,
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
                          'Terminal Kasir',
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
                        const Icon(Icons.table_restaurant,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Meja #04',
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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: Column(
                          children: [
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: surfaceWhite,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _searchQuery.isNotEmpty
                                      ? primary
                                      : borderLight,
                                  width: _searchQuery.isNotEmpty ? 1.4 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _searchQuery.isNotEmpty
                                        ? primary.withOpacity(0.08)
                                        : Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: _searchQuery.isNotEmpty
                                          ? primary
                                          : primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: _searchQuery.isNotEmpty
                                          ? Colors.white
                                          : primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) {
                                        setState(() => _searchQuery = val);
                                      },
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Cari menu makanan / minuman...',
                                        hintStyle:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: textSecondary.withOpacity(0.55),
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        margin:
                                            const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: surface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.close_rounded,
                                            size: 16, color: textSecondary),
                                      ),
                                    ),
                                  Container(
                                    width: 1,
                                    height: 22,
                                    color: borderLight,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: primary,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          content: Text(
                                            'Kamera Barcode / QR Scanner siap digunakan',
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: surface,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: borderLight, width: 0.8),
                                      ),
                                      child: Icon(
                                        Icons.qr_code_scanner_rounded,
                                        color: primary,
                                        size: 19,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _categories.map((cat) {
                                  bool isActive = _activeCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _activeCategory = cat),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? primary
                                              : surfaceWhite,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isActive
                                                ? primary
                                                : borderLight,
                                            width: 1,
                                          ),
                                          boxShadow: isActive
                                              ? [
                                                  BoxShadow(
                                                    color: primary
                                                        .withOpacity(0.25),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          cat,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isActive
                                                ? Colors.white
                                                : textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: primaryLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.search_off_rounded,
                                            color: primary, size: 28),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Menu tidak ditemukan',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tidak ada menu yang cocok dengan kata kunci "$_searchQuery".',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final item = filteredProducts[index];
                            final int currentQty =
                                _getItemQty(item['name'] as String);

                            return Container(
                              decoration: BoxDecoration(
                                color: surfaceWhite,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: borderLight, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(19)),
                                        child: AspectRatio(
                                          aspectRatio: 1.35,
                                          child: Image.network(
                                            item['img'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color: primaryLight,
                                              child: Icon(Icons.local_cafe,
                                                  color: primary, size: 30),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (item['tag'] != null)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.92),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              item['tag'],
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (item['cat'] as String)
                                                    .toUpperCase(),
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: primary,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['name'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: textPrimary,
                                                  height: 1.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['desc'],
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: textSecondary,
                                                  height: 1.15,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _formatRp(item['price']),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: primary,
                                                  ),
                                                ),
                                              ),
                                              if (currentQty == 0)
                                                InkWell(
                                                  onTap: () => _addItem(item),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: primaryLight,
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                    ),
                                                    child: Icon(Icons.add,
                                                        color: primary, size: 18),
                                                  ),
                                                )
                                              else
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: primary,
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                        onTap: () => _removeItem(
                                                            item['name']),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(2),
                                                          child: Icon(
                                                              Icons.remove,
                                                              size: 14,
                                                              color: Colors.white),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 4),
                                                        child: Text(
                                                          currentQty.toString(),
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () =>
                                                            _addItem(item),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(2),
                                                          child: Icon(Icons.add,
                                                              size: 14,
                                                              color: Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _cart.isEmpty
          ? null
          : Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.shopping_bag_outlined,
                                  color: Colors.white, size: 20),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    totalCartItems.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatRp(total),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$totalCartItems Item • Termasuk PB1',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _showCartSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Bayar',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/jadwal');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: secondary,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500, fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'POS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
