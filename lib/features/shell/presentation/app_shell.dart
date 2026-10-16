import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cart/presentation/cart_cubit.dart';
import '../../cart/presentation/cart_page.dart';
import '../../products/presentation/products_page.dart';
import '../../profile/presentation/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _pages = [ProductsPage(), CartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final count = context.select((CartCubit cubit) => cubit.state.itemCount);
    return LayoutBuilder(
      builder: (context, constraints) {
        final expandedNavigation = constraints.maxWidth >= 600;
        final body = IndexedStack(index: _selectedIndex, children: _pages);
        if (expandedNavigation) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 1024,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      size: 34,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: Text('Shop'),
                    ),
                    NavigationRailDestination(
                      icon: _CartIcon(count: count),
                      selectedIcon: _CartIcon(count: count, selected: true),
                      label: const Text('Cart'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: _CartIcon(count: count),
                selectedIcon: _CartIcon(count: count, selected: true),
                label: 'Cart',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, this.selected = false});
  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0,
    label: Text(count > 99 ? '99+' : '$count'),
    child: Icon(selected ? Icons.shopping_bag : Icons.shopping_bag_outlined),
  );
}
