import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'markdown_editor_screen.dart';
import 'pdf_preview_screen.dart';
import 'pdf_reader_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final currentIndex = appState.currentTabIndex;
        final isLargeScreen = MediaQuery.sizeOf(context).width >= 900;

        final screens = [
          PdfReaderScreen(appState: appState),
          MarkdownEditorScreen(appState: appState),
          PdfPreviewScreen(appState: appState),
          SettingsScreen(appState: appState),
        ];

        if (isLargeScreen) {
          // Desktop / Tablet Layout mit seitlicher NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) => appState.setTabIndex(index),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.chrome_reader_mode_outlined),
                      selectedIcon: Icon(Icons.chrome_reader_mode),
                      label: Text('Reader'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.edit_note_outlined),
                      selectedIcon: Icon(Icons.edit_note),
                      label: Text('Editor'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.picture_as_pdf_outlined),
                      selectedIcon: Icon(Icons.picture_as_pdf),
                      label: Text('Vorschau'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Optionen'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile / kompaktes Layout mit NavigationBar
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => appState.setTabIndex(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chrome_reader_mode_outlined),
                selectedIcon: Icon(Icons.chrome_reader_mode),
                label: 'Reader',
              ),
              NavigationDestination(
                icon: Icon(Icons.edit_note_outlined),
                selectedIcon: Icon(Icons.edit_note),
                label: 'Editor',
              ),
              NavigationDestination(
                icon: Icon(Icons.picture_as_pdf_outlined),
                selectedIcon: Icon(Icons.picture_as_pdf),
                label: 'Export',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Optionen',
              ),
            ],
          ),
        );
      },
    );
  }
}
