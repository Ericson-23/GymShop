import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'products.dart';
import 'banners.dart';
import 'auth.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const GymStoreApp(),
    ),
  );
}

class CartProvider extends ChangeNotifier {
  final List<Product> _cart = [];

  List<Product> get cart => _cart;

  int get itemCount => _cart.length;

  double get total => _cart.fold(0, (sum, product) => sum + product.price);

  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners(); // Updates UI automatically
  }

  void removeFromCart(int index) {
    _cart.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class TodoProvider extends ChangeNotifier {
  final List<TodoItem> _todos = [];

  List<TodoItem> get todos => _todos;

  void addTodo(String title) {
    _todos.add(TodoItem(title: title));
    notifyListeners();
  }

  void toggleTodo(int index) {
    _todos[index].isCompleted = !_todos[index].isCompleted;
    notifyListeners();
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }
}

class TodoItem {
  String title;
  bool isCompleted;

  TodoItem({required this.title, this.isCompleted = false});
}

class GymStoreApp extends StatelessWidget {
  const GymStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Gym Store',
          theme: themeProvider.currentTheme,
          initialRoute: '/login-check',
          routes: {
            '/login-check': (context) => const LoginCheckPage(),
            '/home': (context) => const MainNavigationPage(),
            '/about': (context) => const AboutPage(),
            '/contact': (context) => const ContactPage(),
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignUpPage(),
            '/push-demo': (context) => const PushDemoPage(),
            '/media-demo': (context) => const MediaDemoPage(),
            '/video-audio-player': (context) => const VideoAudioPlayerPage(),
          },
        );
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

  PreferredSizeWidget _buildAppBar() {
    switch (_selectedIndex) {
      case 0: // Home
        return AppBar(
          title: const Text("Gym Store"),
          actions: [
            IconButton(
              icon: Icon(
                context.watch<ThemeProvider>().isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CartPage(),
                      ),
                    );
                  },
                ),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.itemCount == 0) return const SizedBox();
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          "${cartProvider.itemCount}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    );
                  },
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
                            Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "₱${product.price.toStringAsFixed(2)}",
                              style: GoogleFonts.roboto(fontSize: 14),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<CartProvider>().addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "${product.name} added to cart")),
                                );
                              },
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
        return const ProfilePage();
      case 2: // Settings
        return const SettingsPage();
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
              leading: const Icon(Icons.photo_library),
              title: const Text('Media & Features Demo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/media-demo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Video + Audio Player'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/video-audio-player');
              },
            ),
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
          Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 4),
                      image: const DecorationImage(
                        image: AssetImage('assets/banners/banner 1.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    currentUser?.name ?? "Guest",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currentUser?.email ?? "guest@example.com",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.fitness_center,
                          size: 40, color: Colors.red[700]),
                      Icon(Icons.favorite, size: 40, color: Colors.pink[400]),
                      Icon(Icons.star, size: 40, color: Colors.amber[600]),
                      Icon(Icons.verified, size: 40, color: Colors.green[600]),
                    ],
                  ),
                ],
              ),
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
    _tabController = TabController(length: 4, vsync: this);
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
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: "Chats"),
            Tab(icon: Icon(Icons.circle), text: "Status"),
            Tab(icon: Icon(Icons.call), text: "Calls"),
            Tab(icon: Icon(Icons.check_circle), text: "To-Do"),
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
              const TodoListTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class TodoListTab extends StatefulWidget {
  const TodoListTab({super.key});

  @override
  State<TodoListTab> createState() => _TodoListTabState();
}

class _TodoListTabState extends State<TodoListTab> {
  final _todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                  decoration: const InputDecoration(
                    labelText: "Add a task",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_todoController.text.isNotEmpty) {
                    context.read<TodoProvider>().addTodo(_todoController.text);
                    _todoController.clear();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              if (todoProvider.todos.isEmpty) {
                return const Center(child: Text("No tasks yet!"));
              }
              return ListView.builder(
                itemCount: todoProvider.todos.length,
                itemBuilder: (context, index) {
                  final todo = todoProvider.todos[index];
                  return ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) {
                        context.read<TodoProvider>().toggleTodo(index);
                      },
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<TodoProvider>().removeTodo(index);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class MediaDemoPage extends StatefulWidget {
  const MediaDemoPage({super.key});

  @override
  State<MediaDemoPage> createState() => _MediaDemoPageState();
}

class _MediaDemoPageState extends State<MediaDemoPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _iconSize = 40;
  Color _iconColor = Colors.blue;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource('audio/sample.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Media & Features Demo")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("6. Local Image (Image.asset)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Image.asset('assets/banners/banner 1.jpg', height: 150),
          const Divider(height: 30),
          const Text("7. Internet Image (Image.network)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Image.network(
            'https://picsum.photos/400/200',
            height: 150,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const Divider(height: 30),
          const Text("8. Circular Border Image (BoxDecoration)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 5),
                image: const DecorationImage(
                  image: AssetImage('assets/banners/banner 2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Divider(height: 30),
          const Text("9. Images from Assets in GridView",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: banners.length + products.length,
              itemBuilder: (context, index) {
                String imagePath;
                if (index < banners.length) {
                  imagePath = banners[index];
                } else {
                  imagePath = products[index - banners.length].image;
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                );
              },
            ),
          ),
          const Divider(height: 30),
          const Text("10-11. Video Player with Controls",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideoPlayerPage()),
              );
            },
            child: const Text("Open Video Player"),
          ),
          const Divider(height: 30),
          const Text("12. Short Audio Clip Player",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton.icon(
            onPressed: _playAudio,
            icon: const Icon(Icons.play_arrow),
            label: const Text("Play Audio"),
          ),
          const Divider(height: 30),
          const Text("13. Material Icons (Dynamic Color & Size)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.favorite, size: _iconSize, color: _iconColor),
              Icon(Icons.star, size: _iconSize, color: _iconColor),
              Icon(Icons.thumb_up, size: _iconSize, color: _iconColor),
            ],
          ),
          Slider(
            value: _iconSize,
            min: 20,
            max: 80,
            onChanged: (value) => setState(() => _iconSize = value),
          ),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _iconColor = Colors.red),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Red"),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _iconColor = Colors.blue),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Blue"),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _iconColor = Colors.green),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Green"),
              ),
            ],
          ),
          const Divider(height: 30),
          const Text("15-16. Custom Fonts (Poppins & Roboto)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            "This is Poppins Font",
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "This is Roboto Font",
            style:
                GoogleFonts.roboto(fontSize: 20, fontStyle: FontStyle.italic),
          ),
          const Divider(height: 30),
          const Text("18. Gallery/Carousel",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(banners[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/video/sample.mp4')
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: false,
            looping: false,
            showControls: true,
          );
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player with Controls")),
      body: Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class VideoAudioPlayerPage extends StatefulWidget {
  const VideoAudioPlayerPage({super.key});

  @override
  State<VideoAudioPlayerPage> createState() => _VideoAudioPlayerPageState();
}

class _VideoAudioPlayerPageState extends State<VideoAudioPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isVideoPlaying = false;
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/video/sample.mp4')
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: false,
            looping: false,
            showControls: false, // Custom controls
          );
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playVideo() {
    _videoController.play();
    setState(() => _isVideoPlaying = true);
  }

  void _pauseVideo() {
    _videoController.pause();
    setState(() => _isVideoPlaying = false);
  }

  void _stopVideo() {
    _videoController.pause();
    _videoController.seekTo(Duration.zero);
    setState(() => _isVideoPlaying = false);
  }

  Future<void> _playAudio() async {
    await _audioPlayer.play(AssetSource('audio/sample.mp3'));
    setState(() => _isAudioPlaying = true);
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => _isAudioPlaying = false);
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() => _isAudioPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video + Audio Player")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Video Section
            const Text(
              "Video Player",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _chewieController != null
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _playVideo,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: _pauseVideo,
                  icon: const Icon(Icons.pause),
                  label: const Text("Pause"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton.icon(
                  onPressed: _stopVideo,
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            const Divider(height: 40),

            // Audio Section
            const Text(
              "Audio Player",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Icon(
              _isAudioPlaying ? Icons.music_note : Icons.music_off,
              size: 80,
              color: _isAudioPlaying ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _playAudio,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: _pauseAudio,
                  icon: const Icon(Icons.pause),
                  label: const Text("Pause"),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton.icon(
                  onPressed: _stopAudio,
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
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
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cart.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cart.length,
                  itemBuilder: (context, index) {
                    var product = cartProvider.cart[index];
                    return ListTile(
                      leading: Image.asset(product.image, width: 50),
                      title: Text(product.name),
                      subtitle: Text("₱${product.price.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          context.read<CartProvider>().removeFromCart(index);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Total: ₱${cartProvider.total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CheckoutPage(total: cartProvider.total),
                          ),
                        );
                      },
                      child: const Text("Checkout"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

    context.read<CartProvider>().clearCart();

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
