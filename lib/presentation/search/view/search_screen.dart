import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart'; // Import auto_route

@RoutePage()
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _searchHistory = [
    'Flutter Widgets',
    'Dart Programming',
    'State Management',
    'UI Design Trends'
  ]; // Example search history
  final List<String> _trendingSearches = [
    'AI in Mobile',
    'Declarative UI',
    'Cross-platform Dev',
    'WebAssembly'
  ]; // Example trending searches
  final List<String> _discoverItems = [
    'New Features in Flutter 3.22',
    'Optimizing App Performance',
    'Building Offline-first Apps',
    'Advanced Animation Techniques'
  ]; // Example discover items

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query); // Add to history, newest first
        if (_searchHistory.length > 5) {
          _searchHistory.removeLast(); // Keep history to a reasonable size
        }
      });
    }
    // In a real app, you'd navigate to a search results page
    // For now, we'll just print the query.
    print('Searching for: $query');
    // Example: context.pushRoute(SearchResultsRoute(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 隐藏默认返回按钮
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.router.pop(); // Use auto_router to pop
              },
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                maxLines: 1,
                style: const TextStyle(fontSize: 12.0),
                decoration: InputDecoration(
                  hintText: '搜索',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  isCollapsed: true, // 是否折叠 true：包裹内容，false：占满空间
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                ),
                onSubmitted: _performSearch, // Search when enter is pressed
              ),
            ),
            const SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('搜索'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 搜索历史板块 ---
            _buildSectionTitle('搜索历史'),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _searchHistory
                  .map((historyItem) => ActionChip(
                        label: Text(historyItem),
                        onPressed: () {
                          _searchController.text = historyItem;
                          _performSearch(historyItem);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24.0),

            // --- 热搜板块 ---
            _buildSectionTitle('热搜'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _trendingSearches
                  .map((trendingItem) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: InkWell(
                          onTap: () {
                            _searchController.text = trendingItem;
                            _performSearch(trendingItem);
                          },
                          child: Text(
                            trendingItem,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24.0),

            // --- 发现板块 ---
            _buildSectionTitle('发现'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _discoverItems
                  .map((discoverItem) => Card(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        elevation: 1.0,
                        child: ListTile(
                          title: Text(discoverItem),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Handle discovery item tap (e.g., navigate to an article)
                            print('Discovering: $discoverItem');
                          },
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}