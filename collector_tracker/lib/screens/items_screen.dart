import 'package:collector_tracker/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../models/item.dart';
import '../widgets/glass_panel.dart';
import '../widgets/animated_glass_card.dart';
import '../widgets/star_rating.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int? _routeCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      final provider = context.read<ItemProvider>();
      // Read route query params for category filter
      final catParam = GoRouterState.of(
        context,
      ).uri.queryParameters['category'];
      if (catParam != null) {
        _routeCategoryId = int.tryParse(catParam);
        provider.setCategoryFilter(_routeCategoryId);
      } else {
        provider.setCategoryFilter(null);
      }
      provider.fetchItems(refresh: true);
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

  void _clearCategoryFilter() {
    setState(() => _routeCategoryId = null);
    context.read<ItemProvider>().setCategoryFilter(null);
    context.go('/items');
  }

  Future<void> _showItemDialog([Item? item]) async {
    // The list endpoint only returns id, name, rating, image_url, category_id.
    // Fetch full details to get description and acquisition_date.
    Item? fullItem = item;
    if (item != null) {
      fullItem =
          await context.read<ItemProvider>().fetchSingleItem(item.id) ?? item;
    }

    final nameController = TextEditingController(text: fullItem?.name);
    final descController = TextEditingController(text: fullItem?.description);
    int selectedRating = fullItem?.rating ?? 0;
    DateTime? selectedDate = fullItem?.acquisitionDate != null
        ? DateTime.tryParse(fullItem!.acquisitionDate!)
        : null;
    int? selectedCategoryId = fullItem?.categoryId;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final categories = context.read<CategoryProvider>().categories;
            final cs = Theme.of(context).colorScheme;

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 28),
              actionsPadding: const EdgeInsets.all(28),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item == null ? Icons.add_rounded : Icons.edit_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    item == null ? 'New Item' : 'Edit Item',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Name
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.label_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Name is required';
                            if (v.trim().length < 2) return 'Min 2 characters';
                            if (v.trim().length > 100)
                              return 'Max 100 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Description
                        TextFormField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          validator: (v) {
                            if (v != null && v.length > 500)
                              return 'Max 500 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Rating
                        Text(
                          'Rating',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StarRating(
                          rating: selectedRating,
                          onChanged: (v) =>
                              setDialogState(() => selectedRating = v),
                          size: 36,
                        ),
                        const SizedBox(height: 20),
                        // Date
                        Text(
                          'Acquisition Date',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context).colorScheme
                                        .copyWith(
                                          surface: cs.surfaceContainerHighest,
                                        ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outline),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDate != null
                                      ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
                                      : 'Select a date',
                                  style: TextStyle(
                                    color: selectedDate != null
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Category
                        DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.folder_outlined),
                          ),
                          dropdownColor: cs.surfaceContainerHighest,
                          items: categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setDialogState(() => selectedCategoryId = val),
                          validator: (v) =>
                              v == null ? 'Select a category' : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
                FilledButton.icon(
                  icon: Icon(
                    item == null ? Icons.add_rounded : Icons.save_rounded,
                    size: 18,
                  ),
                  label: Text(item == null ? 'Create' : 'Save'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = context.read<ItemProvider>();
                      final data = <String, dynamic>{
                        'name': nameController.text.trim(),
                        'description': descController.text.trim(),
                        if (selectedRating > 0) 'rating': selectedRating,
                        if (selectedDate != null)
                          'acquisition_date':
                              '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(Item item) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: cs.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Delete Item?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text('This will permanently remove "${item.name}".'),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ItemProvider>().deleteItem(item.id);
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(Item item) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null && context.mounted) {
      try {
        await context.read<ItemProvider>().uploadImage(item.id, xfile);
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image uploaded')));
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final pad = w > 800 ? 40.0 : 20.0;

    // Category name lookup
    final catMap = <int, String>{};
    for (final c in categoryProvider.categories) {
      catMap[c.id] = c.name;
    }

    // Active category filter name
    final activeCatId = _routeCategoryId ?? provider.activeCategoryId;
    final activeCatName = activeCatId != null ? catMap[activeCatId] : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ─── Header ───
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 28, pad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeCatName != null ? activeCatName : 'Inventory',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.items.length} items${activeCatName != null ? ' in this category' : ' in your collection'}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add Item'),
                      onPressed: () => _showItemDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category filter chip
                if (activeCatName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Chip(
                      label: Text(
                        activeCatName,
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      deleteIcon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: cs.primary,
                      ),
                      onDeleted: _clearCategoryFilter,
                      backgroundColor: cs.primary.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: cs.primary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                // Search
                GlassPanel(
                  padding: EdgeInsets.zero,
                  borderRadius: 14,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ─── Grid ───
          Expanded(
            child: provider.items.isEmpty && provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: cs.outline),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Try a different search'
                              : 'Start adding items to your collection',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(pad, 0, pad, 100),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: w > 1200
                          ? 4
                          : (w > 800 ? 3 : (w > 500 ? 2 : 1)),
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount:
                        provider.items.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.items.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final item = provider.items[index];
                      return _ItemCard(
                        item: item,
                        categoryName: item.categoryId != null
                            ? catMap[item.categoryId]
                            : null,
                        onEdit: () => _showItemDialog(item),
                        onDelete: () => _confirmDelete(item),
                        onPickImage: () => _pickImage(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final String? categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPickImage;

  const _ItemCard({
    required this.item,
    this.categoryName,
    required this.onEdit,
    required this.onDelete,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedGlassCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: item.imageUrl != null
                      ? Image.network(
                          '${ApiService.baseUrl}${item.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _Placeholder(color: cs.outline),
                        )
                      : _Placeholder(color: cs.outline),
                ),
                // Rating badge
                if (item.rating != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${item.rating}',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Camera
                Positioned(
                  top: 10,
                  left: 10,
                  child: Material(
                    color: cs.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onPickImage,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Category + Date row
                  Row(
                    children: [
                      if (categoryName != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categoryName!,
                            style: TextStyle(
                              color: cs.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (item.acquisitionDate != null)
                        Text(
                          item.acquisitionDate!,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Description is not returned by list API
                  Expanded(
                    child:
                        item.description != null && item.description!.isNotEmpty
                        ? Text(
                            item.description!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            'Tap to view details',
                            style: TextStyle(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      const Spacer(),
                      _Btn(
                        icon: Icons.edit_outlined,
                        color: cs.onSurfaceVariant,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 2),
                      _Btn(
                        icon: Icons.delete_outline,
                        color: cs.error.withValues(alpha: 0.7),
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Color color;
  const _Placeholder({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Center(child: Icon(Icons.image_outlined, size: 40, color: color)),
  );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    ),
  );
}
