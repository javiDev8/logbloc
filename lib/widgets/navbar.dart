import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:logbloc/config/locales.dart';
import 'package:logbloc/pools/pools.dart';
import 'package:logbloc/pools/screen_index_pool.dart';
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
                icon: Icon(MdiIcons.notebookOutline),
                label: Tr.models.getString(context),
              ),
              NavigationDestination(
                icon: Icon(MdiIcons.calendarText),
                label: Tr.agenda.getString(context),
              ),
              NavigationDestination(
                icon: Icon(Icons.menu),
                //label: Tr.settings.getString(context),
                label: 'etc'
              ),
            ],
          ),
    );
  }
}
