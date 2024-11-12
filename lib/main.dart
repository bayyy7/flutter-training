import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          // 1. Updated color scheme with a more modern palette
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4), // Purple primary color
            secondary: const Color(0xFF625B71),
            tertiary: const Color(0xFF7D5260),
            brightness: Brightness.light,
          ),
          // Enhanced text theme
          textTheme: const TextTheme(
            displayMedium: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          // Enhanced card theme
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Enhanced button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  // 3. Add history feature
  var history = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    history.add(current); // Add to history when generating new word
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  // 5. Remove favorite word
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  // 6. Clear history
  void clearHistory() {
    history.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2: // 3. Add History page
        page = HistoryPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_outline),
            label: "Favorites",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: "History",
          ),
        ],
      ),
      body: Container(
        child: page,
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: const Text('Like'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'You have ${appState.favorites.length} favorite words.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...appState.favorites.map(
            (pair) => ListTile(
              title: Text(
                pair.asLowerCase,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // 2. Show snackbar on tap
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("It's ${pair.asLowerCase}!"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              // 5. Remove favorite on long press
              onLongPress: () {
                appState.removeFavorite(pair);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Removed ${pair.asLowerCase}"),
                    duration: const Duration(seconds: 1),
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

// 3. New History Page
class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History (${appState.history.length} words)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // 6. Clear history button
                ElevatedButton.icon(
                  onPressed: appState.history.isEmpty
                      ? null
                      : () {
                          appState.clearHistory();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("History cleared"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appState.history.length,
              itemBuilder: (context, index) {
                final pair = appState.history[appState.history.length - 1 - index];
                return ListTile(
                  title: Text(
                    pair.asLowerCase,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // 4. Show snackbar on tap
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(pair.asLowerCase),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}