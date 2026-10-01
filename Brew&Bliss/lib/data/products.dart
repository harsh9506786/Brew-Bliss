// ==========================================================
// SINGLE SOURCE OF TRUTH FOR ALL COFFEES
// Image, name, price, rating - change it here once and it
// updates on Home, All Products and Product Detail.
// ==========================================================

class Product {
  final String image;
  final String name;
  final String description;
  final String rating;
  final String reviews;
  final String price;
  final String category;
  final bool isPopular;

  const Product({
    required this.image,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.category,
    this.isPopular = false,
  });

  // Numeric value of the price string ('₹249' -> 249.0), used for cart totals.
  double get priceValue =>
      double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
}

const List<Product> allProducts = [
  // ---------------- POPULAR (shown on Home) ----------------
  Product(
    image:
        'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&w=600&q=85',
    name: 'Cappuccino',
    description: 'Rich espresso with silky steamed milk foam',
    rating: '4.8',
    reviews: '1.2K+',
    price: '₹249',
    category: 'Cappuccino',
    isPopular: true,
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=85',
    name: 'Caffe Latte',
    description: 'Smooth espresso blended with creamy milk',
    rating: '4.9',
    reviews: '1.1K+',
    price: '₹279',
    category: 'Latte',
    isPopular: true,
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?auto=format&fit=crop&w=600&q=85',
    name: 'Espresso',
    description: 'Bold and intense freshly brewed espresso',
    rating: '4.7',
    reviews: '986+',
    price: '₹179',
    category: 'Espresso',
    isPopular: true,
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1497515114629-f71d768fd07c?auto=format&fit=crop&w=600&q=85',
    name: 'Americano',
    description: 'Espresso balanced with hot water',
    rating: '4.7',
    reviews: '874+',
    price: '₹199',
    category: 'Americano',
    isPopular: true,
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?auto=format&fit=crop&w=600&q=85',
    name: 'Mocha',
    description: 'Espresso with chocolate and steamed milk',
    rating: '4.8',
    reviews: '923+',
    price: '₹299',
    category: 'Mocha',
    isPopular: true,
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=85',
    name: 'Caramel Macchiato',
    description: 'Espresso, vanilla, milk and caramel drizzle',
    rating: '4.9',
    reviews: '1K+',
    price: '₹319',
    category: 'Macchiato',
    isPopular: true,
  ),

  // ---------------- MORE COFFEES (All Products only) ----------------
  Product(
    image:
        'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=85',
    name: 'Cold Brew',
    description: 'Slow-steeped coffee with a smooth bold finish',
    rating: '4.8',
    reviews: '780+',
    price: '₹269',
    category: 'Cold Brew',
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1537286164997-b6a9bbac8b55?auto=format&fit=crop&w=600&q=85',
    name: 'Flat White',
    description: 'Velvety microfoam with rich espresso',
    rating: '4.8',
    reviews: '690+',
    price: '₹259',
    category: 'Flat White',
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1550071555-917d67a1188f?auto=format&fit=crop&w=600&q=85',
    name: 'Vanilla Latte',
    description: 'Creamy latte with smooth vanilla flavor',
    rating: '4.9',
    reviews: '820+',
    price: '₹289',
    category: 'Latte',
  ),
  Product(
    image:
        'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?auto=format&fit=crop&w=600&q=85',
    name: 'Double Espresso',
    description: 'Two shots of rich and concentrated espresso',
    rating: '4.8',
    reviews: '610+',
    price: '₹219',
    category: 'Espresso',
  ),
];

List<Product> get popularProducts =>
    allProducts.where((p) => p.isPopular).toList();

// Every distinct coffee category, in catalogue order (used by Menu chips).
List<String> get productCategories {
  final seen = <String>[];
  for (final p in allProducts) {
    if (!seen.contains(p.category)) seen.add(p.category);
  }
  return seen;
}
