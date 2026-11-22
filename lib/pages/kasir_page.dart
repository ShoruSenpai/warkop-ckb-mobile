import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../config/app_config.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import 'main_tab_screen.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _activeCategory = 'Semua';
  String _orderType = 'Dine In';
  String _selectedTable = 'Meja 01';
  String _paymentMethod = 'QRIS';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, String>> _availableTables = [
    // Indoor
    {'name': 'Meja 01', 'area': 'Indoor', 'desc': 'Kapasitas 4 orang'},
    {'name': 'Meja 02', 'area': 'Indoor', 'desc': 'Kapasitas 4 orang'},
    {'name': 'Meja 03', 'area': 'Indoor', 'desc': 'Kapasitas 4 orang'},
    {'name': 'Meja 04', 'area': 'Indoor', 'desc': 'Kapasitas 6 orang'},
    {'name': 'Meja 05', 'area': 'Indoor', 'desc': 'Kapasitas 6 orang'},
    {'name': 'Meja 06', 'area': 'Indoor', 'desc': 'Kapasitas 2 orang'},
    {'name': 'Meja 07', 'area': 'Indoor', 'desc': 'Kapasitas 2 orang'},
    {'name': 'Meja 08', 'area': 'Indoor', 'desc': 'Kapasitas 4 orang'},
    {'name': 'Meja 09', 'area': 'Indoor', 'desc': 'Kapasitas 4 orang'},
    {'name': 'Meja 10', 'area': 'Indoor', 'desc': 'Kapasitas 8 orang (VIP)'},
    // Outdoor / Smoking
    {'name': 'Meja 11', 'area': 'Outdoor', 'desc': 'Smoking • Kanopi'},
    {'name': 'Meja 12', 'area': 'Outdoor', 'desc': 'Smoking • Kanopi'},
    {'name': 'Meja 13', 'area': 'Outdoor', 'desc': 'Smoking • Kanopi'},
    {'name': 'Meja 14', 'area': 'Outdoor', 'desc': 'Smoking • Garden'},
    {'name': 'Meja 15', 'area': 'Outdoor', 'desc': 'Smoking • Garden'},
    {'name': 'Meja 16', 'area': 'Outdoor', 'desc': 'Smoking • Garden'},
    {'name': 'Meja 17', 'area': 'Outdoor', 'desc': 'Smoking • Panggung'},
    {'name': 'Meja 18', 'area': 'Outdoor', 'desc': 'Smoking • Panggung'},
    {'name': 'Meja 19', 'area': 'Outdoor', 'desc': 'Smoking • Teras'},
    {'name': 'Meja 20', 'area': 'Outdoor', 'desc': 'Smoking • Teras'},
    // Lesehan
    {'name': 'Lesehan 01', 'area': 'Lesehan', 'desc': 'Karpet Gazebo A'},
    {'name': 'Lesehan 02', 'area': 'Lesehan', 'desc': 'Karpet Gazebo B'},
    {'name': 'Lesehan 03', 'area': 'Lesehan', 'desc': 'Karpet Gazebo C'},
    {'name': 'Lesehan 04', 'area': 'Lesehan', 'desc': 'Karpet Gazebo D'},
  ];

  final Color primary = AppColors.primary;
  final Color primaryDark = AppColors.primaryDark;
  final Color primaryLight = AppColors.primaryLight;
  final Color secondary = AppColors.secondary;
  final Color surface = AppColors.surface;
  final Color surfaceWhite = AppColors.surfaceContainerLowest;
  final Color textPrimary = AppColors.onSurface;
  final Color textSecondary = AppColors.onSurfaceVariant;
  final Color borderLight = AppColors.borderLight;
  final Color successBg = AppColors.successBg;
  final Color successText = const Color(0xFF15803D);

  static final List<Map<String, dynamic>> _defaultOfflineProducts = [
    {
      'id': 1,
      'cat': 'Kopi Susu',
      'name': 'Kopi Susu Cak Kebo',
      'desc': 'Gula aren organik, double espresso',
      'price': 18000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuARybcadp9pYMQHJULLtF0871NifTwt1KSueZDE_gbnnaIFzKWeun-ksPIfMnBJiU7JfBvI2PVHHLzbxrCBwkliATgfRgqyPolB0sAemmbjbDaST9aSLDwEhGtxi0Y7Cke9U_pwhWZx9JvdQVdnN_GapDmRB5h_IrQD4LSmg6dmO6qnnJeoP5tqSjQh1Uf1o11LULqrEUOQshES8RR1bdPn3I4xG5f2QXEtcDRqv9ZUz-vTSn6PxIgfjQ',
      'tag': 'Favorit'
    },
    {
      'id': 2,
      'cat': 'Manual Brew',
      'name': 'Espresso Single',
      'desc': 'Arabica Gayo wash 30ml',
      'price': 15000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDaaCnJp_jl4wJMguixT2C0oEHKSxcYq0r-Huao-aYpCmZmyaSx1SFz1d9QrN2m2HlryQ3Ys0R2eVFH1X-RnwAe_kkHbpAvZ_7eCVWZhrNXsdP9D198BpZOKeFtSmDThI2lJUUeK8Hkx6VxVBRGLJ1RvB2zSPO3oWw2KtxO71BkJGU0s7jKFQlxoJOPZQQPD2XyTZRvQPEy_Fg2B6pZH38UBT-k5pq2mnvPn5Mz8JWRTqjTcFTZ5-3Bvg',
    },
    {
      'id': 3,
      'cat': 'Manual Brew',
      'name': 'Americano Dingin',
      'desc': 'Clean body, fruity notes',
      'price': 16000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuACU9VPBe25t4rbG5HD7MD4VIc-EHESgrVYRomYzRxUH4G8zwtKI2sQy0kobtwQ6xYhycuf_J0iDZE2OvY-nUyijfE7W201nJEAXMKTlcCeKYPZ0WyNxXJPPxPoOtvrH6G4jR8lf6yoofCFODIYwrUTMtT7bMVUG6IRtBplAX5tnVjc8RRCx0HxJ4E72dnyT50ImQspGp_0PQt0MxPFvZq9-LRCjw8Crpt47CwHw_q55141Npux5fC49A',
    },
    {
      'id': 4,
      'cat': 'Non-Kopi',
      'name': 'Matcha Latte',
      'desc': 'Uji matcha murni dengan oatmilk',
      'price': 26000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCnpi1EXgLfpIPOEQdbBOMduUZJfOn7_NWpMByE83_vlrNg3m-Gk8QLAvwMDzmPxaWUpUPOVy9Rhix5f_FmJUTS_O594-iuiCQOg8qSmU3lfww7rootD3cHNEm65SpSBCoznf3N8zJOU7INbtMuHMUBG49xAlFE9TN_dEzZGjVRM3YAx2vEIYCFpbzUUfFz1kS9fhaaBLkRzfQEFPJaqwI3Vtsgnm-3n26NOVBP-gGwi2e1r03u-AKXAw',
      'tag': 'Artisan'
    },
    {
      'id': 5,
      'cat': 'Camilan Tradisional',
      'name': 'Pisang Goreng Wijen',
      'desc': 'Pisang kepok madu, renyah wangi',
      'price': 16000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD8Cux6ikayaCbNXUstL6MLPbuBqkSoVxxLO8vtzWkBj-UotkPdW0ctLjPjN3lC8LzSqZnj9yaMJ5Ivz6VxUJWB3-AquCCrfRwdW3yFz5W7BKlD9dkvVvWNE705IIxQd2pnsA57CVM2-WUq4IY14Hd8PsUbvj4S7K1PLHeiM7AUNX0n4jgMACj0czPW8Oc6irEW08UwH80yxLiPE8yo6W8SO2KiXoZLSAZXfciP3jMOVpu6BKlQ_UBDrw',
    },
    {
      'id': 6,
      'cat': 'Makanan Berat',
      'name': 'Nasi Goreng Kampung',
      'desc': 'Telur mata sapi, acar segar',
      'price': 28000,
      'img':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC1h55M00RisBoFXM7SiZuNbZU-TFfVNorP_7c_66_IJiqCYVY9kMfs_Jiq5NHChRW26tZbrYOrsD29cQEjCiFWtScsJsUOLrV6Wbis-vjfEqjGsvNo1i446x0VzTZu8Du4ccPMoQ5MGogmnRGdNb27wmM1FrsX2f79L44Vl-ZoHtIF3nlCDmlKFcpoVvPRQCgpvrFuM_J8hpsth2_aCdRYxqdwh4TnJUCjlTJIyp0NytFtmv_W5tGltQ',
    },
  ];

  // Data produk dimuat dari Supabase
  List<String> _categories = ['Semua'];

  List<Map<String, dynamic>> _products = [];
  bool _loadingProducts = true;
  String? _loadError;
  bool _submitting = false;

  final List<Map<String, dynamic>> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final client = Supabase.instance.client;
      final catRows = await client
          .from('categories')
          .select('id, name')
          .order('id', ascending: true);
      final catMap = <int, String>{};
      for (final c in catRows) {
        catMap[int.tryParse(c['id'].toString()) ?? 0] = c['name'].toString();
      }

      final prodRows = await client
          .from('products')
          .select()
          .eq('status', 'available')
          .order('name', ascending: true);

      final list = <Map<String, dynamic>>[];
      final cats = <String>[];

      for (final p in prodRows) {
        final catId = int.tryParse(p['category_id']?.toString() ?? '') ?? 0;
        final catName = catMap[catId] ?? 'Lainnya';
        if (!cats.contains(catName)) cats.add(catName);

        list.add({
          'id': p['id'],
          'cat': catName,
          'name': (p['name'] ?? '').toString(),
          'desc': (p['description'] ?? '').toString(),
          'price': (p['base_price'] is num)
              ? (p['base_price'] as num).round()
              : int.tryParse(p['base_price']?.toString() ?? '0') ?? 0,
          'img': (p['image_url'] ?? '').toString(),
          'tag': p['is_recommended'] == true ? 'Favorit' : null,
        });
      }

      if (!mounted) return;
      setState(() {
        _products = list;
        _categories = ['Semua', ...cats];
        if (!_categories.contains(_activeCategory)) _activeCategory = 'Semua';
        _loadingProducts = false;
        _loadError = null;
      });
    } catch (e) {
      debugPrint('Error loading products from Supabase: $e');
      if (!mounted) return;
      final cats = <String>[];
      for (final p in _defaultOfflineProducts) {
        final c = p['cat'].toString();
        if (!cats.contains(c)) cats.add(c);
      }
      setState(() {
        _products = _defaultOfflineProducts;
        _categories = ['Semua', ...cats];
        if (!_categories.contains(_activeCategory)) _activeCategory = 'Semua';
        _loadingProducts = false;
        _loadError = null;
      });
    }
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: primary, size: 40),
            const SizedBox(height: 12),
            Text(
              _loadError ?? 'Gagal memuat menu',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadingProducts = true;
                  _loadError = null;
                });
                _loadProducts();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkout(BuildContext sheetContext) async {
    if (_submitting || _cart.isEmpty) return;
    _submitting = true;
    showDialog(
      context: sheetContext,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final snapshot = _cart.map((e) => Map<String, dynamic>.from(e)).toList();
      final sub = snapshot.fold<int>(
          0, (s, i) => s + (i['price'] as int) * (i['qty'] as int));
      final tax = (sub * AppConfig.taxRate).round();
      final total = sub + tax;
      final now = DateTime.now();
      final invCode = 'CKB-${now.millisecondsSinceEpoch.toString().substring(5)}';

      Map<String, dynamic>? createdOrder;
      try {
        final client = Supabase.instance.client;
        
        // Cari shift kasir yang sedang aktif jika ada
        int cashierShiftId = 1;
        try {
          final activeShift = await client
              .from('cashier_shifts')
              .select('id')
              .eq('status', 'open')
              .order('id', ascending: false)
              .limit(1)
              .maybeSingle();
          if (activeShift != null && activeShift['id'] != null) {
            cashierShiftId = int.tryParse(activeShift['id'].toString()) ?? 1;
          }
        } catch (_) {}

        final cashierIdInt = int.tryParse(Session.employeeId.toString()) ?? 1;
        final orderTypeVal = _orderType == 'Take Away' ? 'take_away' : 'dine_in';

        final res = await client.from('orders').insert({
          'invoice_code': invCode,
          'cashier_shift_id': cashierShiftId,
          'cashier_id': cashierIdInt,
          'cashier_name_snapshot':
              Session.name.isNotEmpty ? Session.name : 'Maya Putri',
          'store_name_snapshot': AppConfig.outletName,
          'status': 'completed',
          'order_type': orderTypeVal,
          'gross_amount': sub,
          'discount_amount': 0,
          'final_amount': total,
          'payment_method': _paymentMethod.toLowerCase(),
          'payment_status': 'paid',
          'transaction_time': now.toUtc().toIso8601String(),
          'paid_at': now.toUtc().toIso8601String(),
          'receipt_issued_at': now.toUtc().toIso8601String(),
        }).select().maybeSingle();

        createdOrder = res;

        if (createdOrder != null && createdOrder['id'] != null) {
          final orderId = createdOrder['id'];
          for (final item in snapshot) {
            final pPrice = (item['price'] as int);
            final pQty = (item['qty'] as int);
            final pId = int.tryParse(item['id'].toString()) ?? 7;
            final itemSubtotal = pPrice * pQty;

            await client.from('order_items').insert({
              'order_id': orderId,
              'product_id': pId,
              'product_name_snapshot': item['name'],
              'variant_summary_snapshot': item['variant'] != null &&
                      item['variant'].toString().isNotEmpty
                  ? item['variant'].toString()
                  : null,
              'quantity': pQty,
              'unit_price': pPrice,
              'option_price': 0,
              'discount_amount': 0,
              'subtotal': itemSubtotal,
              'final_subtotal': itemSubtotal,
            });
          }
        }
      } catch (dbErr) {
        debugPrint('Error inserting order to Supabase: $dbErr');
      }

      if (!mounted) return;
      if (sheetContext.mounted) {
        Navigator.of(sheetContext).pop(); // tutup loading
        Navigator.of(sheetContext).pop(); // tutup keranjang
      }
      setState(() => _cart.clear());
      final tableLabel = _orderType == 'Take Away' ? 'Take Away' : _selectedTable;
      Navigator.pushNamed(context, '/pesanan_berhasil', arguments: {
        'code': createdOrder?['invoice_code'] ?? invCode,
        'order_type': _orderType,
        'table': tableLabel,
        'terminal_id': tableLabel,
        'payment_method': _paymentMethod,
        'subtotal': sub,
        'tax': tax,
        'total': total,
        'created_at': now.toIso8601String(),
        'items': snapshot,
      });
    } catch (e) {
      if (mounted) {
        if (sheetContext.mounted) {
          Navigator.of(sheetContext).pop(); // tutup loading
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      _submitting = false;
    }
  }

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
          'id': product['id'],
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

  void _showTablePicker(BuildContext context, [StateSetter? modalState]) {
    String filterArea = 'Semua';
    final customTableCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (pickerCtx) {
        return StatefulBuilder(
          builder: (context, setPickerState) {
            final areas = ['Semua', 'Indoor', 'Outdoor', 'Lesehan'];
            final filteredTables = filterArea == 'Semua'
                ? _availableTables
                : _availableTables.where((t) => t['area'] == filterArea).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 12,
                left: 18,
                right: 18,
              ),
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
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
                            'Pilih Meja / Lokasi',
                            style: AppTextStyles.h2,
                          ),
                          Text(
                            'Pilih meja tamu atau pesanan bawa pulang',
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: surface,
                          foregroundColor: textSecondary,
                        ),
                        onPressed: () => Navigator.pop(pickerCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Pilihan take away
                  InkWell(
                    onTap: () {
                      setState(() {
                        _orderType = 'Take Away';
                      });
                      if (modalState != null) {
                        modalState(() {});
                      }
                      Navigator.pop(pickerCtx);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _orderType == 'Take Away' ? primary.withOpacity(0.08) : surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _orderType == 'Take Away' ? primary : borderLight,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _orderType == 'Take Away' ? primary : surfaceWhite,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.takeout_dining,
                              size: 18,
                              color: _orderType == 'Take Away' ? Colors.white : textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bungkus / Take Away',
                                  style: AppTextStyles.cardTitle,
                                ),
                                Text(
                                  'Pesanan dibawa pulang tanpa nomor meja',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          if (_orderType == 'Take Away')
                            Icon(Icons.check_circle, color: primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter area meja
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: areas.map((area) {
                        final isActive = filterArea == area;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(area),
                            selected: isActive,
                            onSelected: (selected) {
                              if (selected) {
                                setPickerState(() => filterArea = area);
                              }
                            },
                            selectedColor: primary,
                            backgroundColor: surface,
                            labelStyle: AppTextStyles.subtitle.copyWith(color: isActive ? Colors.white : textSecondary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isActive ? primary : borderLight,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Daftar meja
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: filteredTables.length,
                      itemBuilder: (context, idx) {
                        final t = filteredTables[idx];
                        final isSelected = _orderType == 'Dine In' && _selectedTable == t['name'];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTable = t['name']!;
                              _orderType = 'Dine In';
                            });
                            if (modalState != null) {
                              modalState(() {});
                            }
                            Navigator.pop(pickerCtx);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? primary : surfaceWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? primary : borderLight,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  t['area'] == 'Lesehan'
                                      ? Icons.weekend
                                      : Icons.table_restaurant,
                                  size: 20,
                                  color: isSelected ? Colors.white : primary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t['name']!,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.cardTitle.copyWith(color: isSelected ? Colors.white : textPrimary),
                                ),
                                Text(
                                  t['desc']!,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.overline.copyWith(color: isSelected ? Colors.white.withOpacity(0.85) : textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Input nomor meja manual
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderLight),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note, size: 20, color: textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: customTableCtrl,
                            style: AppTextStyles.body,
                            decoration: const InputDecoration(
                              hintText: 'Atau ketik meja kustom (cth: VIP Room)',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final text = customTableCtrl.text.trim();
                            if (text.isNotEmpty) {
                              setState(() {
                                _selectedTable = text;
                                _orderType = 'Dine In';
                              });
                              if (modalState != null) modalState(() {});
                              Navigator.pop(pickerCtx);
                            }
                          },
                          child: Text(
                            'Pilih',
                            style: AppTextStyles.captionBold.copyWith(color: primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
            int tax = (subtotal * AppConfig.taxRate).round();
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
                                style: AppTextStyles.h2,
                              ),
                              InkWell(
                                onTap: () => _showTablePicker(sheetContext, setModalState),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$totalItems Item Terpilih • ${_orderType == "Take Away" ? "Take Away / Bungkus" : _selectedTable}',
                                        style: AppTextStyles.subtitle.copyWith(color: primary),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit_outlined, size: 13, color: primary),
                                    ],
                                  ),
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
                                  style: AppTextStyles.bodyBold.copyWith(color: isActive ? Colors.white : textSecondary),
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
                              style: AppTextStyles.body.copyWith(color: textSecondary),
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
                                          style: AppTextStyles.cardTitle,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatRp(item['price']),
                                          style: AppTextStyles.subtitle.copyWith(color: primary),
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
                                            style: AppTextStyles.cardTitle,
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
                        style: AppTextStyles.bodyBold,
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
                                  style: AppTextStyles.captionBold.copyWith(color: isActive ? primary : textSecondary),
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
                                  style: AppTextStyles.body,
                                ),
                                Text(
                                  _formatRp(subtotal),
                                  style: AppTextStyles.bodyBold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pajak Resto (PB1 10%)',
                                  style: AppTextStyles.body,
                                ),
                                Text(
                                  _formatRp(tax),
                                  style: AppTextStyles.bodyBold,
                                ),
                              ],
                            ),
                            Divider(color: borderLight, height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Tagihan',
                                  style: AppTextStyles.h4,
                                ),
                                Text(
                                  _formatRp(total),
                                  style: AppTextStyles.h1.copyWith(color: primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _cart.isEmpty ? null : () => _checkout(sheetContext),
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
                          style: AppTextStyles.button,
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
    super.build(context);
    int subtotal = _cart.fold(
        0, (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));
    int tax = (subtotal * AppConfig.taxRate).round();
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
                      final tabScope = TabNavigationScope.of(context);
                      if (tabScope != null && tabScope.currentIndex != 0) {
                        tabScope.switchTo(0);
                      } else if (Navigator.canPop(context)) {
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
                          style: AppTextStyles.overline.copyWith(color: Colors.white.withOpacity(0.85), height: 1.1),
                        ),
                        Text(
                          'Terminal Kasir',
                          style: AppTextStyles.h2.copyWith(color: Colors.white, height: 1.15),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showTablePicker(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                          Icon(
                            _orderType == 'Take Away'
                                ? Icons.takeout_dining
                                : Icons.table_restaurant,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _orderType == 'Take Away'
                                ? 'Take Away'
                                : _selectedTable,
                            style: AppTextStyles.captionBold.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ),
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: surfaceWhite.withOpacity(0.82),
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(
                                      color: _searchQuery.isNotEmpty
                                          ? primary.withOpacity(0.65)
                                          : Colors.white.withOpacity(0.9),
                                      width: _searchQuery.isNotEmpty ? 1.3 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _searchQuery.isNotEmpty
                                            ? primary.withOpacity(0.08)
                                            : const Color(0xFF64748B).withOpacity(0.06),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.7),
                                        blurRadius: 4,
                                        offset: const Offset(0, -1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, right: 8),
                                        child: Icon(
                                          Icons.search_rounded,
                                          color: _searchQuery.isNotEmpty
                                              ? primary
                                              : textSecondary.withOpacity(0.65),
                                          size: 21,
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: (val) {
                                            setState(() => _searchQuery = val);
                                          },
                                          style: AppTextStyles.bodyLargeBold.copyWith(
                                            color: textPrimary,
                                          ),
                                          cursorColor: primary,
                                          decoration: InputDecoration(
                                            hintText: 'Cari menu makanan / minuman...',
                                            hintStyle: AppTextStyles.body.copyWith(
                                              color: textSecondary.withOpacity(0.5),
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                                            margin: const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              color: textSecondary.withOpacity(0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 15,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(0xFF1E293B),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.qr_code_scanner_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      'Kamera Barcode / QR Scanner siap digunakan',
                                                      style: AppTextStyles.body.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.95),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: borderLight.withOpacity(0.8),
                                              width: 0.8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.04),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.qr_code_scanner_rounded,
                                            color: primary,
                                            size: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                          style: AppTextStyles.captionBold.copyWith(color: isActive ? Colors.white : textSecondary),
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
                        child: _loadingProducts
                            ? const Center(child: CircularProgressIndicator())
                            : _loadError != null
                                ? _buildLoadError()
                                : filteredProducts.isEmpty
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
                                        style: AppTextStyles.h3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tidak ada menu yang cocok dengan kata kunci "$_searchQuery".',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body,
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
                                              style: AppTextStyles.overline.copyWith(color: primary),
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
                                                style: AppTextStyles.overline.copyWith(color: primary, letterSpacing: 0.5),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['name'],
                                                style: AppTextStyles.cardTitle.copyWith(height: 1.2),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item['desc'],
                                                style: AppTextStyles.caption.copyWith(height: 1.15),
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
                                                  style: AppTextStyles.cardTitle.copyWith(color: primary),
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
                                                          style: AppTextStyles
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
                              style: AppTextStyles.h3.copyWith(color: Colors.white),
                            ),
                            Text(
                              '$totalCartItems Item • Termasuk PB1',
                              style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.7)),
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
                            style: AppTextStyles.button,
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
      bottomNavigationBar: TabNavigationScope.of(context) != null
          ? null
          : BottomNavigationBar(
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
              selectedLabelStyle: AppTextStyles.captionBold,
              unselectedLabelStyle: AppTextStyles.caption,
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
