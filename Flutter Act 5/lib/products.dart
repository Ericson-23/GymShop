class Product {
  final String name;
  final double price;
  final String category;
  final String image;

  Product({
    required this.name,
    required this.price,
    required this.category,
    required this.image,
  });
}

final products = [
  Product(
    name: "Creatine",
    price: 1200.0,
    category: "Supplements",
    image: "assets/banners/crea.jpg",
  ),
  Product(
    name: "Whey Protein",
    price: 2500.0,
    category: "Supplements",
    image: "assets/banners/whey.jpg",
  ),
  Product(
    name: "Gym Gloves",
    price: 900.0,
    category: "Accessories",
    image: "assets/banners/gloves.jpg",
  ),
  Product(
    name: "Fitness Shirt",
    price: 1100.0,
    category: "Apparel",
    image: "assets/banners/shirt.jpg",
  ),
];
