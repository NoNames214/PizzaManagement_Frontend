import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/UI/AI/ai_discovery.dart';
import 'package:pizza_management/UI/cart/cart.dart';
import 'package:pizza_management/UI/profile/profile.dart';
import 'package:pizza_management/UI/review/review.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/repository/category_repository.dart';
import '../../data/api/api_constant.dart';
import '../../data/model/category.dart';
import '../admin/admin.dart';
import '../pizza_screen/pizza_screen.dart';
import '../search/search.dart';

class Home extends StatefulWidget {
  final String token;
  final String? role;

  const Home({
    super.key,
    required this.token,
    this.role,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Category>> _categories;
  int _currentIndex = 0;
  bool isLoading = true;
  late final AIRecommendScreen aiScreen;
  final logger = Logger();
  List<Pizza> pizzas = [];
  final GlobalKey<AIRecommendState> aiKey = GlobalKey<AIRecommendState>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categories = CategoryRepository().getCategories();
    aiScreen = AIRecommendScreen(key: aiKey, token: widget.token);
  }

  Future<void> refreshRecommend() async {
    aiKey.currentState?.loadAIData();
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildHomeContent(),
        const CartScreen(),
        aiScreen,
        const ReviewScreen(),
        const Profile(),
        if (widget.role == "Admin") const AdminScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        if (isDesktop) {
          return _buildDesktop();
        }
        return _buildMobile();
      },
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildColorBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildBody(),
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildDesktop() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xffFFF3EB),
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text("Home"),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.shopping_cart),
                label: Text("Cart"),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.auto_awesome),
                label: Text("AI"),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.reviews),
                label: Text("Review"),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text("Profile"),
              ),
              if (widget.role == "Admin")
                const NavigationRailDestination(
                  icon: Icon(Icons.admin_panel_settings),
                  label: Text("Admin"),
                ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFE57351),
                    Color(0xFFFFCC80),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: _buildBody(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Positioned(
      bottom: 18,
      left: 15,
      right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withAlpha(60)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_filled, "Home", 0),
                _buildNavItem(Icons.shopping_cart, "Cart", 1),
                _buildNavItem(Icons.auto_awesome, "AI", 2),
                _buildNavItem(Icons.reviews_outlined, "Review", 3),
                _buildNavItem(Icons.person, "Profile", 4),
                if (widget.role == "Admin")
                  _buildNavItem(Icons.admin_panel_settings, "Admin", 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
          color: const Color(0xFFE57351),
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withAlpha(70),
              size: 24,
            ),
            if (isSelected) const SizedBox(width: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final desktop = _isDesktop(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          _buildSearchBar(context),
          const SizedBox(height: 25),
          _buildTheUsualBanner(desktop),
          const SizedBox(height: 25),
          _buildQuickFilters(desktop),
          const SizedBox(height: 30),
          Text(
            "Categories",
            style: TextStyle(
              fontSize: desktop ? 32 : 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          _buildMenuGrid(desktop),
          SizedBox(height: desktop ? 40 : 120),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(80)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
              settings: const RouteSettings(arguments: 1),
            ),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Search delicious pizza...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorBackground() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFE57351), Color(0xFFFFCC80)],
      ),
    ),
  );

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bonjour,', style: TextStyle(color: Colors.white70, fontSize: 15)),
          SizedBox(height: 2),
          Text(
            'Hungry for Pizza?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.notifications_none, color: Colors.white),
      ),
    ],
  );

  Widget _buildQuickFilters(bool isDesktop) => SizedBox(
    height: isDesktop ? 80 : 65,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Icons.local_pizza,
        Icons.local_drink,
        Icons.icecream,
        Icons.lunch_dining,
        Icons.fastfood,
      ]
          .map(
            (icon) => Container(
          margin: const EdgeInsets.only(right: 16),
          padding: EdgeInsets.all(isDesktop ? 18 : 14),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(90),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isDesktop ? 28 : 22,
          ),
        ),
      )
          .toList(),
    ),
  );

  Widget _buildTheUsualBanner(bool isDesktop) => Container(
    height: isDesktop ? 180 : 130,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE57351), Color(0xFFFFCC80)],
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(isDesktop ? 28 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Summer Deal\nFree Drink!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 26 : 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 1,
          bottom: 0,
          top: 0,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/category_pizza.png',
                height: isDesktop ? 350 : 110,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.local_pizza,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildMenuGrid(bool isDesktop) => FutureBuilder<List<Category>>(
    future: _categories,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }
      if (snapshot.hasError) {
        return Center(
          child: Text(
            "Error: ${snapshot.error}",
            style: const TextStyle(color: Colors.white),
          ),
        );
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(
          child: Text(
            "No categories found",
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: isDesktop ? 20 : 14,
          mainAxisSpacing: isDesktop ? 20 : 14,
          childAspectRatio: isDesktop ? 1.1 : 0.95,
        ),
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final cat = snapshot.data![index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PizzaScreen(
                    categoryId: cat.id,
                    categoryName: cat.name,
                    refreshRecommend: refreshRecommend,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      ApiConstant.categoryImage(cat.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.orange.shade200,
                        child: const Icon(
                          Icons.local_pizza,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                            Colors.black87,
                          ],
                          stops: [0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        cat.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 18 : 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}