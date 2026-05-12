import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ItemProvider>().fetchItems(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<ItemProvider>().fetchItems();
      }
    });
  }

  void _onSearchChanged(String value) {
    context.read<ItemProvider>().fetchItems(refresh: true, search: value);
  }

  void _showItemDialog([Item? item]) {
    final nameController = TextEditingController(text: item?.name);
    final descController = TextEditingController(text: item?.description);
    final ratingController = TextEditingController(text: item?.rating?.toString());
    final dateController = TextEditingController(text: item?.acquisitionDate);
    int? selectedCategoryId = item?.categoryId;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final categories = context.read<CategoryProvider>().categories;

            return AlertDialog(
              title: Text(item == null ? 'New Item' : 'Edit Item'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      TextFormField(
                        controller: ratingController,
                        decoration: const InputDecoration(labelText: 'Rating (1-5)'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(labelText: 'Acquisition Date (YYYY-MM-DD)'),
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: categories.map((cat) {
                          return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedCategoryId = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = context.read<ItemProvider>();
                      final data = {
                        'name': nameController.text,
                        'description': descController.text,
                        if (ratingController.text.isNotEmpty) 'rating': int.tryParse(ratingController.text),
                        if (dateController.text.isNotEmpty) 'acquisition_date': dateController.text,
                        if (selectedCategoryId != null) 'category_id': selectedCategoryId,
                      };
                      try {
                        if (item == null) {
                          await provider.createItem(data);
                        } else {
                          await provider.updateItem(item.id, data);
                        }
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _confirmDelete(Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: Text('Are you sure you want to delete "${item.name}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await context.read<ItemProvider>().deleteItem(item.id);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(Item item) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      if (context.mounted) {
        try {
          await context.read<ItemProvider>().uploadImage(item.id, xfile);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded successfully')));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Error: $e')));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: provider.items.isEmpty && provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : 1),
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.items.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.items.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final item = provider.items[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            item.imageUrl != null
                                ? Image.network('${ApiService.baseUrl}${item.imageUrl}', fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported, size: 64))
                                : const Icon(Icons.image, size: 64, color: Colors.grey),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton.filledTonal(
                                icon: const Icon(Icons.camera_alt),
                                onPressed: () => _pickImage(item),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (item.rating != null)
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < item.rating! ? Icons.star : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                )),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showItemDialog(item)),
                                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _confirmDelete(item)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
