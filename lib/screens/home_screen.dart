import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Product> _cartItems = [];
  double _totalAmount = 0.0;
  double _totalGST = 0.0;
  double _totalCGST = 0.0;
  double _totalSGST = 0.0;
  String _customerName = '';
  String _customerGSTIN = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GST Billing',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedIndex == 0) // Show cart icon only on dashboard
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    _showCartDialog();
                  },
                ),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Dashboard
          _buildDashboard(),
          // Invoices
          _buildInvoices(),
          // Reports
          _buildReports(),
          // Settings
          _buildSettings(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt),
            label: 'Invoices',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataDisplayScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                icon: Icons.add_shopping_cart,
                title: 'New Bill',
                onTap: () {
                  _showNewBillDialog();
                },
              ),
              _buildDashboardCard(
                icon: Icons.history,
                title: 'Bill History',
                onTap: () {
                  // TODO: Navigate to bill history
                },
              ),
              _buildDashboardCard(
                icon: Icons.people,
                title: 'Customers',
                onTap: () {
                  // TODO: Navigate to customers
                },
              ),
              _buildDashboardCard(
                icon: Icons.inventory,
                title: 'Products',
                onTap: () {
                  // TODO: Navigate to products
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoices() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getBills(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final bills = snapshot.data?.docs ?? [];

        if (bills.isEmpty) {
          return Center(
            child: Text(
              'No bills found',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            final bill = bills[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  bill['customerName'] ?? 'Unknown Customer',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GSTIN: ${bill['customerGSTIN'] ?? 'N/A'}',
                      style: GoogleFonts.poppins(),
                    ),
                    Text(
                      'Total: ₹${bill['grandTotal'].toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '${bill['items']?.length ?? 0} items',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  // TODO: Show bill details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReports() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.getBills(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final bills = snapshot.data?.docs ?? [];
        double totalSales = 0;
        double totalGST = 0;

        for (var bill in bills) {
          final data = bill.data() as Map<String, dynamic>;
          totalSales += data['grandTotal'] ?? 0;
          totalGST += data['totalGST'] ?? 0;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales Report',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildReportRow('Total Bills', bills.length.toString()),
                      _buildReportRow('Total Sales', '₹${totalSales.toStringAsFixed(2)}'),
                      _buildReportRow('Total GST', '₹${totalGST.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return const Center(
      child: Text('Settings'),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.blue.shade900,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewBillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'New Bill',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Customer GSTIN (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showProductSelectionDialog();
              },
              child: const Text('Add Products'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Products',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Sample products
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Product ${index + 1}'),
                    subtitle: Text('₹${(index + 1) * 100}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _addToCart(Product(
                          name: 'Product ${index + 1}',
                          price: (index + 1) * 100.0,
                          gstRate: 18.0,
                        ));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCartDialog();
            },
            child: const Text('View Cart'),
          ),
        ],
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_cartItems.isEmpty)
              const Center(
                child: Text('Cart is empty'),
              )
            else
              Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final product = _cartItems[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          'Price: ₹${product.price}\nGST: ${product.gstRate}%',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _cartItems.removeAt(index);
                              _calculateTotals();
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildTotalRow('Subtotal', _totalAmount),
                        _buildTotalRow('CGST', _totalCGST),
                        _buildTotalRow('SGST', _totalSGST),
                        _buildTotalRow('Total GST', _totalGST),
                        _buildTotalRow(
                          'Grand Total',
                          _totalAmount + _totalGST,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateBill();
            },
            child: const Text('Generate Bill'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _totalAmount = 0.0;
    _totalGST = 0.0;
    _totalCGST = 0.0;
    _totalSGST = 0.0;

    for (var product in _cartItems) {
      _totalAmount += product.price;
      final gstAmount = (product.price * product.gstRate) / 100;
      _totalGST += gstAmount;
      _totalCGST += gstAmount / 2;
      _totalSGST += gstAmount / 2;
    }
  }

  void _generateBill() async {
    try {
      final billData = {
        'customerName': _customerName,
        'customerGSTIN': _customerGSTIN,
        'items': _cartItems.map((item) => {
          'name': item.name,
          'price': item.price,
          'gstRate': item.gstRate,
        }).toList(),
        'subtotal': _totalAmount,
        'cgst': _totalCGST,
        'sgst': _totalSGST,
        'totalGST': _totalGST,
        'grandTotal': _totalAmount + _totalGST,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseService.addBill(billData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _cartItems.clear();
          _calculateTotals();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating bill: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final double price;
  final double gstRate;

  Product({
    required this.name,
    required this.price,
    required this.gstRate,
  });
} 