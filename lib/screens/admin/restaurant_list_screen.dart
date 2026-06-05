import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import 'restaurant_form_screen.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Restoran"),
      ),
      body: StreamBuilder(
        stream: provider.getRestaurantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada restoran"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final restaurantId = docs[index].id;

              return Card(
                child: ListTile(
                  leading: data['imageUrl'] != null && data['imageUrl'] != ""
                      ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.restaurant),
                  title: Text(data['name'] ?? "Tanpa nama"),
                  subtitle: Text(data['address'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RestaurantFormScreen(
                                restaurantId: restaurantId,
                                initialData: data,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await provider.deleteRestaurant(restaurantId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Restoran dihapus")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RestaurantFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
