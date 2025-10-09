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
      initialRoute: '/login-check',
      routes: {
        '/login-check': (context) => const LoginCheckPage(),
        '/home': (context) => const MainNavigationPage(),
        '/about': (context) => const AboutPage(),
        '/contact': (context) => const ContactPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/push-demo': (context) => const PushDemoPage(),
      },
    );
  }
}

class LoginCheckPage extends StatefulWidget {
  const LoginCheckPage({super.key});

  @override
  State<LoginCheckPage> createState() => _LoginCheckPageState();
}

class _LoginCheckPageState extends State<LoginCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUser = prefs.getString("loggedInUser");

    if (savedUser != null) {
      currentUser = registeredUsers.firstWhere(
        (u) => u.username == savedUser,
        orElse: () => UserAccount(
          name: "",
          username: "",
          email: "",
          password: "",
        ),
      );

      if (currentUser != null && currentUser!.username.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _productTabController;
  List<Product> cart = [];

  final categories = ["Supplements", "Accessories", "Apparel"];

  @override
  void initState() {
    super.initState();
    _productTabController =
        TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _productTabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} added to cart")),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    switch (_selectedIndex) {
      case 0: // Home
        return AppBar(
          title: const Text("Gym Store"),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(cart: cart),
                      ),
                    );
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _productTabController,
            tabs: categories.map((c) => Tab(text: c)).toList(),
          ),
        );
      case 1: // Profile
        return AppBar(
          title: const Text("Profile"),
        );
      case 2: // Settings
        return AppBar(
          title: const Text("Settings"),
        );
      default:
        return AppBar(title: const Text("Gym Store"));
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: // Home
        return Column(
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
                controller: _productTabController,
                children: categories.map((category) {
                  var filtered =
                      products.where((p) => p.category == category).toList();
                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                              child: Image.asset(product.image,
                                  fit: BoxFit.contain),
                            ),
                            Text(product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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
        );
      case 1: // Profile
        return ProfilePage();
      case 2: // Settings
        return SettingsPage();
      default:
        return const Center(child: Text("Unknown page"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser?.name ?? "Guest",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    currentUser?.email ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contact');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Push vs PushReplacement Demo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/push-demo');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("loggedInUser");
                currentUser = null;
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 60),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Name"),
              subtitle: Text(currentUser?.name ?? "Guest"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.alternate_email),
              title: const Text("Username"),
              subtitle: Text(currentUser?.username ?? "N/A"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(currentUser?.email ?? "N/A"),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: "Chats"),
            Tab(icon: Icon(Icons.circle), text: "Status"),
            Tab(icon: Icon(Icons.call), text: "Calls"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView(
                children: const [
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Customer Support"),
                    subtitle: Text("How can we help you?"),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.store)),
                    title: Text("Gym Store Updates"),
                    subtitle: Text("New products available!"),
                  ),
                ],
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.circle, size: 80, color: Colors.green),
                    SizedBox(height: 20),
                    Text("Your status: Active", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.call_received, color: Colors.green),
                    title: Text("Customer Support"),
                    subtitle: Text("Yesterday, 3:45 PM"),
                  ),
                  ListTile(
                    leading: Icon(Icons.call_made, color: Colors.blue),
                    title: Text("Delivery Hotline"),
                    subtitle: Text("2 days ago, 10:20 AM"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Gym Store",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your one-stop shop for all gym and fitness needs!",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "We offer:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("• Premium supplements"),
            const Text("• Quality gym accessories"),
            const Text("• Comfortable fitness apparel"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get in Touch",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text("Phone"),
                subtitle: const Text("+63 912 345 6789"),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.red),
                title: const Text("Email"),
                subtitle: const Text("support@gymstore.com"),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: const Text("Address"),
                subtitle: const Text("123 Fitness Street, Manila, Philippines"),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}

class PushDemoPage extends StatelessWidget {
  const PushDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Push vs PushReplacement Demo"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Screen 1",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PushDemoSecondPage(usedPush: true),
                    ),
                  );
                },
                child: const Text("Go to Screen 2 using push()"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PushDemoSecondPage(usedPush: false),
                    ),
                  );
                },
                child: const Text("Go to Screen 2 using pushReplacement()"),
              ),
              const SizedBox(height: 40),
              const Text(
                "push() keeps Screen 1 in navigation stack\npushReplacement() removes Screen 1",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PushDemoSecondPage extends StatelessWidget {
  final bool usedPush;

  const PushDemoSecondPage({super.key, required this.usedPush});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen 2"),
        automaticallyImplyLeading: usedPush,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Screen 2",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                usedPush
                    ? "You used push() - Back button is available"
                    : "You used pushReplacement() - No back button!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: usedPush ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              if (!usedPush)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text("Go to Home (using named route)"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                  _eWalletOption = null;
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

      Navigator.pushReplacementNamed(context, '/home');
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
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}

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
