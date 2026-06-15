import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shop/domain/entities/product.dart';
import '../../../shop/presentation/providers/products_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:bustedworld/core/utils/currency_formatter.dart';

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('MANAGE PRODUCTS', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: cs.secondary),
            onPressed: () {
               _showAddProductModal(context, ref);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (products.isEmpty) {
            return Center(child: Text('No products available.', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)));
          }

          final bool isDesktop = constraints.maxWidth > 900;
          
          if (isDesktop) {
            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductTile(context, products[index], ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductTile(context, products[index], ref),
          );
        },
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cardShape = const BeveledRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: cardShape.copyWith(
        side: BorderSide(color: cs.outline.withOpacity(0.3), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline.withOpacity(0.5), width: 1.5),
          ),
          child: product.imageUrl.startsWith('data:image') 
              ? Image.memory(base64Decode(product.imageUrl.split(',').last), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.error))
              : Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.error)),
        ),
        title: Text(product.title.toUpperCase(), style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${formatRupiah(product.price)} - ${product.category.toUpperCase()}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('STOCK: S:${product.stockPerSize["S"]} M:${product.stockPerSize["M"]} L:${product.stockPerSize["L"]} XL:${product.stockPerSize["XL"]}', style: tt.bodySmall?.copyWith(fontSize: 10, color: cs.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_note, color: cs.secondary),
              tooltip: 'Edit product',
              onPressed: () {
                _showEditProductModal(context, ref, product);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error),
              tooltip: 'Delete product',
              onPressed: () {
                 ref.read(productsProvider.notifier).removeProduct(product.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return const AddProductForm();
      }
    );
  }

  void _showEditProductModal(BuildContext context, WidgetRef ref, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return EditProductForm(product: product);
      }
    );
  }
}

class AddProductForm extends ConsumerStatefulWidget {
  const AddProductForm({super.key});

  @override
  ConsumerState<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends ConsumerState<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  double price = 0.0;
  String imageUrl = '';
  String category = 'baju';
  String description = '';
  int stockS = 0, stockM = 0, stockL = 0, stockXL = 0;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await pickedFile.readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          imageUrl = 'data:image/jpeg;base64,$base64Str';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to read image: $e')));
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('ADD NEW PRODUCT', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'TITLE'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => title = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'PRICE'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid price' : null,
                onSaved: (val) => price = double.parse(val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: _isUploading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : Icon(Icons.image_outlined, color: cs.primary),
                      label: Text(imageUrl.isEmpty ? 'UPLOAD PHOTO' : 'PHOTO SELECTED'),
                      onPressed: _isUploading ? null : _pickImage,
                    ),
                  ),
                  if (imageUrl.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outline, width: 1.5),
                      ),
                      child: imageUrl.startsWith('data:image') 
                        ? Image.memory(base64Decode(imageUrl.split(',').last), fit: BoxFit.cover)
                        : Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  ],
                ],
              ),
              if (imageUrl.isEmpty) 
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Image is required', style: TextStyle(color: cs.error, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'DESCRIPTION'),
                onSaved: (val) => description = val ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: ['baju', 'celana', 'aksesoris', 'topi'].contains(category.toLowerCase())
                    ? category.toLowerCase()
                    : 'baju',
                decoration: const InputDecoration(labelText: 'CATEGORY'),
                items: ['baju', 'celana', 'aksesoris', 'topi'].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => category = val);
                  }
                },
                onSaved: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              Text('STOCK PER SIZE', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: cs.primary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(
                children: [
                    Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'S'), keyboardType: TextInputType.number, onSaved: (val) => stockS = int.tryParse(val ?? '0') ?? 0)),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'M'), keyboardType: TextInputType.number, onSaved: (val) => stockM = int.tryParse(val ?? '0') ?? 0)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                    Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'L'), keyboardType: TextInputType.number, onSaved: (val) => stockL = int.tryParse(val ?? '0') ?? 0)),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'XL'), keyboardType: TextInputType.number, onSaved: (val) => stockXL = int.tryParse(val ?? '0') ?? 0)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && imageUrl.isNotEmpty) {
                    _formKey.currentState!.save();
                    final newProduct = Product(
                      id: const Uuid().v4(),
                      title: title,
                      price: price,
                      imageUrl: imageUrl,
                      category: category,
                      description: description,
                      rating: 5.0,
                      stockPerSize: {"S": stockS, "M": stockM, "L": stockL, "XL": stockXL},
                      createdAt: DateTime.now(),
                    );
                    ref.read(productsProvider.notifier).addProduct(newProduct);
                    Navigator.pop(context);
                  } else if (imageUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload an image first.')));
                  }
                },
                child: const Text('SAVE PRODUCT'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProductForm extends ConsumerStatefulWidget {
  final Product product;
  const EditProductForm({super.key, required this.product});

  @override
  ConsumerState<EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends ConsumerState<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late double price;
  late String imageUrl;
  late String category;
  late String description;
  late int stockS, stockM, stockL, stockXL;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    title = widget.product.title;
    price = widget.product.price;
    imageUrl = widget.product.imageUrl;
    category = widget.product.category;
    description = widget.product.description;
    stockS = widget.product.stockPerSize['S'] ?? 0;
    stockM = widget.product.stockPerSize['M'] ?? 0;
    stockL = widget.product.stockPerSize['L'] ?? 0;
    stockXL = widget.product.stockPerSize['XL'] ?? 0;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await pickedFile.readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          imageUrl = 'data:image/jpeg;base64,$base64Str';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to read image: $e')));
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('EDIT PRODUCT', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'TITLE'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => title = val!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'PRICE'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid price' : null,
                onSaved: (val) => price = double.parse(val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: _isUploading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : Icon(Icons.image_outlined, color: cs.primary),
                      label: Text(imageUrl.isEmpty ? 'UPLOAD PHOTO' : 'PHOTO SELECTED'),
                      onPressed: _isUploading ? null : _pickImage,
                    ),
                  ),
                  if (imageUrl.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outline, width: 1.5),
                      ),
                      child: imageUrl.startsWith('data:image') 
                        ? Image.memory(base64Decode(imageUrl.split(',').last), fit: BoxFit.cover)
                        : Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'DESCRIPTION'),
                onSaved: (val) => description = val ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: ['baju', 'celana', 'aksesoris', 'topi'].contains(category.toLowerCase())
                    ? category.toLowerCase()
                    : 'baju',
                decoration: const InputDecoration(labelText: 'CATEGORY'),
                items: ['baju', 'celana', 'aksesoris', 'topi'].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => category = val);
                  }
                },
                onSaved: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              Text('STOCK PER SIZE', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: cs.primary, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(
                children: [
                   Expanded(child: TextFormField(initialValue: stockS.toString(), decoration: const InputDecoration(labelText: 'S'), keyboardType: TextInputType.number, onSaved: (val) => stockS = int.tryParse(val ?? '0') ?? 0)),
                   const SizedBox(width: 8),
                   Expanded(child: TextFormField(initialValue: stockM.toString(), decoration: const InputDecoration(labelText: 'M'), keyboardType: TextInputType.number, onSaved: (val) => stockM = int.tryParse(val ?? '0') ?? 0)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   Expanded(child: TextFormField(initialValue: stockL.toString(), decoration: const InputDecoration(labelText: 'L'), keyboardType: TextInputType.number, onSaved: (val) => stockL = int.tryParse(val ?? '0') ?? 0)),
                   const SizedBox(width: 8),
                   Expanded(child: TextFormField(initialValue: stockXL.toString(), decoration: const InputDecoration(labelText: 'XL'), keyboardType: TextInputType.number, onSaved: (val) => stockXL = int.tryParse(val ?? '0') ?? 0)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && imageUrl.isNotEmpty) {
                    _formKey.currentState!.save();
                    final updatedProduct = Product(
                      id: widget.product.id,
                      title: title,
                      price: price,
                      imageUrl: imageUrl,
                      category: category,
                      description: description,
                      rating: widget.product.rating,
                      stockPerSize: {"S": stockS, "M": stockM, "L": stockL, "XL": stockXL},
                      createdAt: widget.product.createdAt,
                    );
                    ref.read(productsProvider.notifier).updateProduct(updatedProduct);
                    Navigator.pop(context);
                  }
                },
                child: const Text('SAVE CHANGES'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
