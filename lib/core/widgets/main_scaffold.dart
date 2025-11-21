import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int? _lastTappedIndex;
  DateTime? _lastTapTime;

  int _getCurrentIndex(String route) {
    switch (route) {
      case '/':
        return 0;
      case '/game':
      case '/game/shop':
        return 1; // Oyun sekmesi
      case '/fridge':
        return 1; // Eski buzdolabı route'u da aynı index'e
      case '/reports/weekly':
        return 2;
      case '/settings':
        return 3;
      default:
        // Route game ile başlıyorsa oyun sekmesi
        if (route.startsWith('/game')) {
          return 1;
        }
        return 0;
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    // Aynı index'e tekrar tıklanıyorsa ignore et
    final currentIndex = _getCurrentIndex(widget.currentRoute);
    if (index == currentIndex) {
      return;
    }

    // Çok hızlı tıklamaları engelle (debounce) - performans için
    final now = DateTime.now();
    if (_lastTappedIndex == index && 
        _lastTapTime != null && 
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      return;
    }

    _lastTappedIndex = index;
    _lastTapTime = now;

    if (!mounted) return;

    // Navigation - widget tree tamamen hazır olduğunda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/game');
            break;
          case 2:
            context.go('/reports/weekly');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      } catch (e) {
        // Navigation hatası olsa bile crash etme
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(widget.currentRoute);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = const Color(0xFF38D07F); // Yeşil ana vurgu rengi
    final backgroundColor = isDark ? const Color(0xFF1C1E22) : const Color(0xFFF6F7FA);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: RepaintBoundary(
          child: Container(
            color: backgroundColor,
            child: widget.child,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E22) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: RepaintBoundary(
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(context, index),
              selectedItemColor: selectedColor, // Yeşil (#38D07F)
              unselectedItemColor: isDark 
                  ? Colors.white.withOpacity(0.5) 
                  : Colors.black.withOpacity(0.4),
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              iconSize: 24,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events),
                  label: 'Oyun',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Raporlar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Ayarlar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

