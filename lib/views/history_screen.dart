import 'package:ateam_machinetest/view_model/search_view_model.dart';
import 'package:ateam_machinetest/views/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.of<SearchProvider>(context, listen: false).loadSearches();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Searches'),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return searchProvider.searches.isEmpty
              ? const Center(
                  child: Text(
                    'No saved searches yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: searchProvider.searches.length,
                  itemBuilder: (context, index) {
                    final search = searchProvider.searches[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            '${search.startLocation} to ${search.endLocation}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Searched on ${_formatDate(search.searchDate)}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultsScreen(
                                  startLocation: search.startLocation,
                                  endLocation: search.endLocation,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
