import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const NavApp());

const isAuth = true;

class NavApp extends StatelessWidget {
  const NavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        debugLogDiagnostics: true,
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) => isAuth ? null : '/one',
            builder: (context, state) => const NavHome(),
          ),
          GoRoute(
            path: '/one',
            name: 'one',
            builder: (context, state) {
              return ItemOne(
                id: int.parse(state.queryParams['idGiven']!),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NavHome extends StatelessWidget {
  const NavHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nav Home'),
      ),
      body: Center(
        child: Column(
          children: [
            IconButton(
              onPressed: () => context.pushNamed(
                'one',
                queryParams: <String, dynamic>{
                  'idGiven': 111.toString(),
                },
              ),
              icon: const Text('Push One'),
            ),
            IconButton(
              onPressed: () => context.goNamed(
                'one',
                queryParams: <String, dynamic>{
                  // 'nameGiven': 'Anmol',
                  'idGiven': 111,
                },
              ),
              icon: const Text('Go to One'),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemOne extends StatelessWidget {
  final int id;

  const ItemOne({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item 1'),
      ),
      body: Text('This is page for with id: $id'),
    );
  }
}

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                context.go('/one');
              },
            ),
          ],
        ),
      ),
    );
  }
}
