import 'package:logize/config/locales.dart';
import 'package:logize/pools/screen_index_pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class SideNavbar extends StatelessWidget {
  const SideNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ListView(
        children:
            [
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
                ]
                .asMap()
                .entries
                .map(
                  (destEntry) => ListTile(
                    leading: destEntry.value.icon,
                    title: Text(destEntry.value.label),
                    onTap: () {
                      screenIndexPool.set((_) => destEntry.key);
                    },
                  ),
                )
                .toList(),
      ),
    );
  }
}
