import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/main_scaffold.dart';
import 'shop_stickers_screen.dart';
import 'shop_skins_screen.dart';
import 'shop_packages_screen.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
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
    return MainScaffold(
      currentRoute: '/game/shop',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mağaza / Özelleştir'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Stickerlar'),
              Tab(text: 'Kaplamalar'),
              Tab(text: 'Tematik Paketler'),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ShopStickersScreen(),
            ShopSkinsScreen(),
            ShopPackagesScreen(),
          ],
        ),
      ),
    );
  }
}

