import '../models/item_keranjang.dart';
import '../models/produk.dart';

abstract final class CashierCatalog {
  static const categories = [
    'Semua',
    'Kopi Susu',
    'Manual Brew',
    'Non-Kopi',
    'Camilan Tradisional',
    'Makanan Berat',
  ];

  static const products = [
    Product(
      id: 'kopi-susu-cak-kebo',
      category: 'Kopi Susu',
      name: 'Kopi Susu Cak Kebo',
      description: 'Gula aren organik, double espresso',
      price: 18000,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuARybcadp9pYMQHJULLtF0871NifTwt1KSueZDE_gbnnaIFzKWeun-ksPIfMnBJiU7JfBvI2PVHHLzbxrCBwkliATgfRgqyPolB0sAemmbjbDaST9aSLDwEhGtxi0Y7Cke9U_pwhWZx9JvdQVdnN_GapDmRB5h_IrQD4LSmg6dmO6qnnJeoP5tqSjQh1Uf1o11LULqrEUOQshES8RR1bdPn3I4xG5f2QXEtcDRqv9ZUz-vTSn6PxIgfjQ',
      tag: 'Favorit',
    ),
    Product(
      id: 'espresso-single',
      category: 'Manual Brew',
      name: 'Espresso Single',
      description: 'Arabica Gayo wash 30ml',
      price: 15000,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDaaCnJp_jl4wJMguixT2C0oEHKSxcYq0r-Huao-aYpCmZmyaSx1SFz1d9QrN2m2HlryQ3Ys0R2eVFH1X-RnwAe_kkHbpAvZ_7eCVWZhrNXsdP9D198BpZOKeFtSmDThI2lJUUeK8Hkx6VxVBRGLJ1RvB2zSPO3oWw2KtxO71BkJGU0s7jKFQlxoJOPZQQPD2XyTZRvQPEy_Fg2B6pZH38UBT-k5pq2mnvPn5Mz8JWRTqjTcFTZ5-3Bvg',
    ),
    Product(
      id: 'americano-dingin',
      category: 'Manual Brew',
      name: 'Americano Dingin',
      description: 'Clean body, fruity notes',
      price: 16000,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuACU9VPBe25t4rbG5HD7MD4VIc-EHESgrVYRomYzRxUH4G8zwtKI2sQy0kobtwQ6xYhycuf_J0iDZE2OvY-nUyijfE7W201nJEAXMKTlcCeKYPZ0WyNxXJPPxPoOtvrH6G4jR8lf6yoofCFODIYwrUTMtT7bMVUG6IRtBplAX5tnVjc8RRCx0HxJ4E72dnyT50ImQspGp_0PQt0MxPFvZq9-LRCjw8Crpt47CwHw_q55141Npux5fC49A',
    ),
    Product(
      id: 'matcha-latte',
      category: 'Non-Kopi',
      name: 'Matcha Latte',
      description: 'Uji matcha murni dengan oatmilk',
      price: 26000,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCnpi1EXgLfpIPOEQdbBOMduUZJfOn7_NWpMByE83_vlrNg3m-Gk8QLAvwMDzmPxaWUpUPOVy9Rhix5f_FmJUTS_O594-iuiCQOg8qSmU3lfww7rootD3cHNEm65SpSBCoznf3N8zJOU7INbtMuHMUBG49xAlFE9TN_dEzZGjVRM3YAx2vEIYCFpbzUUfFz1kS9fhaaBLkRzfQEFPJaqwI3Vtsgnm-3n26NOVBP-gGwi2e1r03u-AKXAw',
      tag: 'Artisan',
    ),
    Product(
      id: 'pisang-goreng-wijen',
      category: 'Camilan Tradisional',
      name: 'Pisang Goreng Wijen',
      description: 'Pisang kepok madu, renyah wangi',
      price: 16000,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD8Cux6ikayaCbNXUstL6MLPbuBqkSoVxxLO8vtzWkBj-UotkPdW0ctLjPjN3lC8LzSqZnj9yaMJ5Ivz6VxUJWB3-AquCCrfRwdW3yFz5W7BKlD9dkvVvWNE705IIxQd2pnsA57CVM2-WUq4IY14Hd8PsUbvj4S7K1PLHeiM7AUNX0n4jgMACj0czPW8Oc6irEW08UwH80yxLiPE8yo6W8SO2KiXoZLSAZXfciP3jMOVpu6BKlQ_UBDrw',
    ),
    Product(
      id: 'nasi-goreng-kampung',
      category: 'Makanan Berat',
      name: 'Nasi Goreng Kampung',
      description: 'Telur mata sapi, acar segar',
      price: 28000,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC1h55M00RisBoFXM7SiZuNbZU-TFfVNorP_7c_66_IJiqCYVY9kMfs_Jiq5NHChRW26tZbrYOrsD29cQEjCiFWtScsJsUOLrV6Wbis-vjfEqjGsvNo1i446x0VzTZu8Du4ccPMoQ5MGogmnRGdNb27wmM1FrsX2f79L44Vl-ZoHtIF3nlCDmlKFcpoVvPRQCgpvrFuM_J8hpsth2_aCdRYxqdwh4TnJUCjlTJIyp0NytFtmv_W5tGltQ',
    ),
  ];

  static const initialCart = [
    CartItem(
      productId: 'kopi-susu-cak-kebo',
      name: 'Kopi Susu Cak Kebo',
      variant: 'Normal Ice, Less Sugar',
      price: 18000,
      quantity: 1,
    ),
    CartItem(
      productId: 'pisang-goreng-wijen',
      name: 'Pisang Goreng Wijen',
      variant: 'Topping Cokelat Keju',
      price: 16000,
      quantity: 2,
    ),
    CartItem(
      productId: 'matcha-latte',
      name: 'Matcha Latte',
      variant: 'Substitusi Oatmilk (+Rp 6.000)',
      price: 26000,
      quantity: 1,
    ),
  ];
}
