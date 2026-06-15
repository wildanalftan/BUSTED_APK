import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../shop/presentation/providers/products_provider.dart';
import 'map_picker_page.dart';
import 'package:bustedworld/core/utils/currency_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  LatLng? _pickedLocation;
  String _selectedPayment = 'COD'; // COD, Card, Bank, QRIS
  bool _isGeocoding = false;

  // Card Inputs
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  // Bank Inputs
  String _selectedBank = 'BCA';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result != null) {
      setState(() {
        _pickedLocation = result;
      });
      await _reverseGeocode(result);
    }
  }

  Future<void> _reverseGeocode(LatLng location) async {
    setState(() {
      _isGeocoding = true;
      _addressController.text = 'Resolving physical address from coordinates...';
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1'
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'bustedworld-flutter-shopping-app'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          setState(() {
            _addressController.text = displayName;
            _isGeocoding = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding exception: $e');
    }

    // Fallback
    setState(() {
      _addressController.text = 'Lat: ${location.latitude.toStringAsFixed(5)}, Lng: ${location.longitude.toStringAsFixed(5)}';
      _isGeocoding = false;
    });
  }

  void _payNow() {
    if (ref.read(cartProvider).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('CART IS EMPTY!'), backgroundColor: Theme.of(context).colorScheme.primary),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final cartItems = ref.read(cartProvider);
      final totalPrice = ref.read(cartProvider.notifier).totalPrice;
      final grandTotal = totalPrice + 15000;

      // Construct payment info summary
      String paymentDetail = 'COD';
      if (_selectedPayment == 'Card') {
        paymentDetail = 'Credit Card (*${_cardNumberController.text.substring(_cardNumberController.text.length - 4)})';
      } else if (_selectedPayment == 'Bank') {
        paymentDetail = 'Bank Transfer ($_selectedBank)';
      } else if (_selectedPayment == 'QRIS') {
        paymentDetail = 'QRIS E-Wallet';
      }

      final newOrder = Order(
        userId: FirebaseAuth.instance.currentUser?.uid ?? 'guest',
        customerName: _nameController.text.trim(),
        address: '${_addressController.text.trim()} | Paid via $paymentDetail',
        items: List.from(cartItems),
        totalAmount: grandTotal,
      );

      ref.read(ordersProvider.notifier).addOrder(newOrder);

      // Reduce stock
      for (var item in cartItems) {
        ref.read(productsProvider.notifier).reduceStock(item.product.id, item.selectedSize, item.quantity);
      }

      context.go('/order_success');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('SHIPPING INFO', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'FULL NAME'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 24),

              // --- ADDRESS + MAPS BUTTON ---
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isMobile = constraints.maxWidth < 450;
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'ADDRESS / COORDINATES'),
                          maxLines: 3,
                          readOnly: _isGeocoding,
                          validator: (val) => val == null || val.isEmpty ? 'Please enter delivery address' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _isGeocoding ? null : _openMapPicker,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _pickedLocation != null ? cs.primary : Colors.transparent,
                                border: Border.all(
                                  color: _pickedLocation != null ? cs.primary : cs.onSurfaceVariant,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    color: _pickedLocation != null ? cs.onPrimary : cs.onSurfaceVariant,
                                    size: 28,
                                  ),
                                  if (!isMobile) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'MAPS',
                                      style: TextStyle(
                                        color: _pickedLocation != null ? cs.onPrimary : cs.onSurfaceVariant,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),

              // Show picked location chip
              if (_pickedLocation != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(left: BorderSide(color: cs.primary, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: cs.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isGeocoding ? 'Locating address...' : 'Coordinates resolved',
                          style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _pickedLocation = null;
                            _addressController.clear();
                          });
                        },
                        child: Icon(Icons.close, color: cs.onSurfaceVariant, size: 16),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 48),
              Text('PAYMENT METHOD', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              
              // Selectors
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPaymentTab('COD', 'Cash On Delivery', Icons.money_outlined),
                  _buildPaymentTab('Card', 'Credit Card', Icons.credit_card_outlined),
                  _buildPaymentTab('Bank', 'Bank Transfer', Icons.account_balance_outlined),
                  _buildPaymentTab('QRIS', 'QRIS Pay', Icons.qr_code_2_outlined),
                ],
              ),
              const SizedBox(height: 24),

              // Conditional Payment Inputs
              _buildConditionalPaymentFields(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: cartItems.isEmpty ? null : Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outline, width: 1)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('SUBTOTAL: ${formatRupiah(cartNotifier.totalPrice)}\nSHIPPING: Rp 15.000', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatRupiah(cartNotifier.totalPrice + 15000),
                        style: tt.headlineSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _payNow,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('PLACE ORDER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTab(String key, String label, IconData icon) {
    final isSelected = _selectedPayment == key;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surface,
          border: Border.all(
              color: isSelected ? cs.primary : cs.outline, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionalPaymentFields() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_selectedPayment == 'COD') {
      return Container(
        padding: const EdgeInsets.all(16),
        color: cs.surface,
        child: Row(
          children: [
            Icon(Icons.info_outline, color: cs.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please prepare exact cash sum. You will pay the courier upon receiving the product packages.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedPayment == 'Card') {
      return Container(
        padding: const EdgeInsets.all(20),
        color: cs.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('CREDIT CARD DETAILS',
                style: tt.labelLarge?.copyWith(letterSpacing: 1)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Card Number (16 Digits)'),
              validator: (val) => val == null || val.length != 16 || int.tryParse(val) == null
                  ? 'Please enter a valid 16-digit card number'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cardExpiryController,
                    decoration: const InputDecoration(hintText: 'MM/YY'),
                    validator: (val) => val == null || !val.contains('/') || val.length != 5
                        ? 'Expiry required'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cardCvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'CVV'),
                    validator: (val) => val == null || val.length != 3 || int.tryParse(val) == null
                        ? 'CVV invalid'
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_selectedPayment == 'Bank') {
      return Container(
        padding: const EdgeInsets.all(20),
        color: cs.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('BANK VIRTUAL ACCOUNT',
                style: tt.labelLarge?.copyWith(letterSpacing: 1)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: cs.surface,
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
              value: _selectedBank,
              items: ['BCA', 'Mandiri', 'BNI', 'BRI'].map((bank) {
                return DropdownMenuItem(
                  value: bank,
                  child: Text('$bank Transfer'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedBank = val);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: cs.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VIRTUAL ACCOUNT NUMBER:',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedBank == 'BCA'
                            ? '80777 98218 090'
                            : '90012 34567 890',
                        style: TextStyle(
                            color: cs.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy,
                            color: cs.onSurfaceVariant, size: 16),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Virtual account number copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please transfer exact checkout amount. The system updates status automatically.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // QRIS
    return Container(
      padding: const EdgeInsets.all(20),
      color: cs.surface,
      child: Column(
        children: [
          Text('SCAN QRIS CODE',
              style: tt.labelLarge?.copyWith(letterSpacing: 1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white, // QR code must stay white
            width: 160,
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner,
                    color: Colors.black, size: 100),
                const SizedBox(height: 4),
                Text('BUSTEDWORLD QRIS',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Scan using GoPay, OVO, Dana, LinkAja or Banking App',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
