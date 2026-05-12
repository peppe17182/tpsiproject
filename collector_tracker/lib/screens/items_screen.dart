import 'package:collector_tracker/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../models/item.dart';
import '../models/category.dart';

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
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
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
    final ratingController = TextEditingController(
      text: item?.rating?.toString(),
    );
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              titlePadding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                item == null ? 'New Item' : 'Edit Item',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: ratingController,
                                decoration: const InputDecoration(
                                  labelText: 'Rating (1-5)',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: dateController,
                                decoration: const InputDecoration(
                                  labelText: 'Date (YYYY-MM-DD)',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCategoryId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.all(24),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = context.read<ItemProvider>();
                      final data = {
                        'name': nameController.text,
                        'description': descController.text,
                        if (ratingController.text.isNotEmpty)
                          'rating': int.tryParse(ratingController.text),
                        if (dateController.text.isNotEmpty)
                          'acquisition_date': dateController.text,
                        if (selectedCategoryId != null)
                          'category_id': selectedCategoryId,
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
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await context.read<ItemProvider>().deleteItem(item.id);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload Error: $e')));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.background,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search inventory...',
                prefixIcon: Icon(Icons.search, color: colorScheme.outline),
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
                crossAxisCount: MediaQuery.of(context).size.width > 1200
                    ? 4
                    : (MediaQuery.of(context).size.width > 800 ? 3 : 1),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            item.imageUrl != null
                                ? Image.network(
                                    '${ApiService.baseUrl}${item.imageUrl}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: colorScheme.outlineVariant,
                                    ),
                                  )
                                : Icon(
                                    Icons.image,
                                    size: 64,
                                    color: colorScheme.outlineVariant,
                                  ),
                            if (item.rating != null)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiaryContainer
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: colorScheme.onTertiaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.rating}',
                                        style: TextStyle(
                                          color:
                                              colorScheme.onTertiaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: IconButton.filledTonal(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(
                                    0.5,
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.camera_alt, size: 20),
                                onPressed: () => _pickImage(item),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: colorScheme.surface,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.description ?? 'No description',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      onPressed: () => _showItemDialog(item),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: colorScheme.error,
                                      ),
                                      onPressed: () => _confirmDelete(item),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
