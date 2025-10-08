import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'products.dart';
import 'banners.dart';
import 'auth.dart';

void main() {
  runApp(const GymStoreApp());
}

class GymStoreApp extends StatelessWidget {
  const GymStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Product> cart = [];

  final categories = ["Supplements", "Accessories", "Apparel"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUser = prefs.getString("loggedInUser");

    if (savedUser != null) {
      setState(() {
        currentUser = registeredUsers.firstWhere(
          (u) => u.username == savedUser,
          orElse: () => UserAccount(
            name: "",
            username: "",
            email: "",
            password: "",
          ),
        );
      });
    }
  }

  void _addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} added to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gym Store 🏋️"),
        actions: [
          if (currentUser == null)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ).then((_) => setState(() {}));
              },
            ),
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("loggedInUser");
                setState(() {
                  currentUser = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out")),
                );
              },
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  if (currentUser == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ).then((_) => setState(() {}));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(cart: cart),
                      ),
                    );
                  }
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      "${cart.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 150,
            child: PageView(
              children: banners.map((banner) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(banner, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                var filtered =
                    products.where((p) => p.category == category).toList();
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var product = filtered[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Expanded(
                            child:
                                Image.asset(product.image, fit: BoxFit.contain),
                          ),
                          Text(product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("₱${product.price.toStringAsFixed(2)}"),
                          ElevatedButton(
                            onPressed: () => _addToCart(product),
                            child: const Text("Add to Cart"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- CART PAGE -----------------
class CartPage extends StatelessWidget {
  final List<Product> cart;

  const CartPage({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0, (sum, product) => sum + product.price);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                var product = cart[index];
                return ListTile(
                  leading: Image.asset(product.image, width: 50),
                  title: Text(product.name),
                  subtitle: Text("₱${product.price.toStringAsFixed(2)}"),
                );
              },
            ),
          ),
          Text("Total: ₱${total.toStringAsFixed(2)}",
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutPage(total: total),
                ),
              );
            },
            child: const Text("Checkout"),
          ),
        ],
      ),
    );
  }
}

// ---------------- CHECKOUT PAGE -----------------
class CheckoutPage extends StatefulWidget {
  final double total;

  const CheckoutPage({super.key, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  String? _paymentMethod;
  String? _eWalletOption;
  bool _extraProtection = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _confirmOrder() {
    if (_addressController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _paymentMethod == null ||
        (_paymentMethod == "E-Wallet" && _eWalletOption == null) ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final formattedDate =
        "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}";
    final formattedTime =
        "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Order Confirmed!\n"
          "Address: ${_addressController.text}\n"
          "Contact: ${_contactController.text}\n"
          "Payment: $_paymentMethod"
          "${_paymentMethod == "E-Wallet" ? " ($_eWalletOption)" : ""}\n"
          "Delivery Date: $formattedDate\n"
          "Delivery Time: $formattedTime\n"
          "Extra Protection: ${_extraProtection ? "Yes" : "No"}",
        ),
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                  labelText: "Address", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: "Contact Number", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text("Payment Method:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _paymentMethod,
              items: const [
                DropdownMenuItem(value: "E-Wallet", child: Text("E-Wallet")),
                DropdownMenuItem(value: "COD", child: Text("Cash on Delivery")),
                DropdownMenuItem(
                    value: "Card", child: Text("Credit/Debit Card")),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value;
                  _eWalletOption = null; // reset if changed
                });
              },
            ),
            if (_paymentMethod == "E-Wallet") ...[
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text("GCash"),
                value: _eWalletOption == "GCash",
                onChanged: (_) {
                  setState(() => _eWalletOption = "GCash");
                },
              ),
              CheckboxListTile(
                title: const Text("PayMaya"),
                value: _eWalletOption == "PayMaya",
                onChanged: (_) {
                  setState(() => _eWalletOption = "PayMaya");
                },
              ),
            ],
            const SizedBox(height: 20),
            const Text("Delivery Date and Time:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDate,
                    child: Text(_selectedDate == null
                        ? "Select Date"
                        : "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTime,
                    child: Text(_selectedTime == null
                        ? "Select Time"
                        : "${_selectedTime!.format(context)}"),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            SwitchListTile(
              title: const Text("Extra Protection for Products"),
              value: _extraProtection,
              onChanged: (val) => setState(() => _extraProtection = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _confirmOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                "Confirm Payment (₱${widget.total.toStringAsFixed(2)})",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- LOGIN PAGE -----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final user = registeredUsers.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () =>
          UserAccount(name: "", username: "", email: "", password: ""),
    );

    if (user.username == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    } else {
      currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("loggedInUser", user.username);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome, ${user.name}!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()));
              },
              child: const Text("Don’t have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- SIGNUP PAGE -----------------
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _signUp() {
    String name = _nameController.text;
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (registeredUsers.any((u) => u.username == username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username already exists")),
      );
      return;
    }

    registeredUsers.add(UserAccount(
      name: name,
      username: username,
      email: email,
      password: password,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created! Please log in.")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name")),
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password")),
            TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Confirm Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: const Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}
