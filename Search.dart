//search results

import 'package:flutter/material.dart';

const _results = [
  {'title': 'Flutter Documentation', 'snippet': 'Official Flutter docs...'},
  {'title': 'Flutter Packages', 'snippet': 'Pub.dev package search...'},
];

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                FilterChip(label: const Text('All'), selected: true, onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Images'), selected: false, onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Videos'), selected: false, onSelected: (_) {}),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'Relevance',
                  items: ['Relevance', 'Date'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  title: Text(r['title'] as String),
                  subtitle: Text(r['snippet'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


//search suggestions

import 'package:flutter/material.dart';

const _recent = ['flutter', 'dart', 'widgets'];
const _trending = ['Flutter 3.0', 'Riverpod', 'Go Router'];

class SearchSuggestions extends StatefulWidget {
  const SearchSuggestions({super.key});

  @override
  State<SearchSuggestions> createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {
  final _controller = TextEditingController();
  var _suggestions = <String>[];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final q = _controller.text.toLowerCase();
      if (q.isEmpty) {
        setState(() => _suggestions = []);
      } else {
        setState(() => _suggestions = _recent
            .where((s) => s.contains(q))
            .toList());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
      ),
      body: ListView(
        children: [
          if (_suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Suggestions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            ..._suggestions.map(
              (s) => ListTile(
                leading: const Icon(Icons.search),
                title: Text(s),
                onTap: () {},
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ..._recent.map(
            (s) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(s),
              onTap: () => _controller.text = s,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Trending',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ..._trending.map(
            (s) => ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(s),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}


//Advanced Search

import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  var _category = 'All';
  var _dateRange = 'Any';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Search')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              'All',
              'Docs',
              'Images',
              'Videos',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _dateRange,
            decoration: const InputDecoration(
              labelText: 'Date Range',
              border: OutlineInputBorder(),
            ),
            items: [
              'Any',
              'Today',
              'This Week',
              'This Month',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _dateRange = v ?? _dateRange),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Option A'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Option B'),
                selected: false,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Option C'),
                selected: true,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Search')),
        ],
      ),
    );
  }
}
