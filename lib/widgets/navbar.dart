import 'package:logize/config/locales.dart';
import 'package:logize/pools/pools.dart';
import 'package:logize/pools/screen_index_pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Swimmer<int>(
      pool: screenIndexPool,
      builder:
          (context, rootIndex) => NavigationBar(
            selectedIndex: rootIndex,
            onDestinationSelected: ((index) {
              screenIndexPool.set((_) => index);
            }),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.layers),
                label: Tr.models.getString(context),
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today),
                label: Tr.agenda.getString(context),
              ),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: Tr.settings.getString(context),
              ),
            ],
          ),
    );
  }
}
