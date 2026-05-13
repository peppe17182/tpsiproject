import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../widgets/glass_panel.dart';
import '../widgets/animated_glass_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  void _showCategoryDialog([Category? category]) {
    final nameController = TextEditingController(text: category?.name);
    final descController = TextEditingController(text: category?.description);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
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
                  color: cs.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category == null
                      ? Icons.create_new_folder_outlined
                      : Icons.edit_rounded,
                  color: cs.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                category == null ? 'New Category' : 'Edit Category',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
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
                      if (v.trim().length > 50) return 'Max 50 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    validator: (v) {
                      if (v != null && v.length > 200)
                        return 'Max 200 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                ],
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
                category == null ? Icons.add_rounded : Icons.save_rounded,
                size: 18,
              ),
              label: Text(category == null ? 'Create' : 'Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final provider = context.read<CategoryProvider>();
                  try {
                    if (category == null) {
                      await provider.createCategory(
                        nameController.text.trim(),
                        descController.text.trim(),
                      );
                    } else {
                      await provider.updateCategory(
                        category.id,
                        nameController.text.trim(),
                        descController.text.trim(),
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted)
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(Category category) {
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
              'Delete Category?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'This will permanently remove "${category.name}" and all its items.',
        ),
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
                await context.read<CategoryProvider>().deleteCategory(
                  category.id,
                );
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

  static const _colors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final pad = w > 800 ? 40.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 28, pad, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.categories.length} categories',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: cs.secondary),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('New Category'),
                  onPressed: () => _showCategoryDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─── List ───
          Expanded(
            child: provider.isLoading && provider.categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 64,
                          color: cs.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories yet',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first category to organize items',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(pad, 0, pad, 100),
                    itemCount: provider.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      final color = _colors[index % _colors.length];

                      return AnimatedGlassCard(
                        padding: EdgeInsets.zero,
                        glowColor: color,
                        onTap: () =>
                            context.go('/items?category=${category.id}'),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.folder_rounded,
                              color: color,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          subtitle:
                              category.description != null &&
                                  category.description!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    category.description!,
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_right_rounded,
                                color: cs.onSurfaceVariant,
                                size: 22,
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: cs.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () => _showCategoryDialog(category),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: cs.error.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                                onPressed: () => _confirmDelete(category),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
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
