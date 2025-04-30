import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../providers/firebase_provider.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create invoice screen
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Invoice>>(
        stream: context.read<FirebaseProvider>().getInvoices(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final invoices = snapshot.data ?? [];

          if (invoices.isEmpty) {
            return const Center(
              child: Text('No invoices found'),
            );
          }

          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(invoice.customerName),
                  subtitle: Text(
                    'Total: ₹${invoice.total.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    invoice.date.toString().split(' ')[0],
                  ),
                  onTap: () {
                    // TODO: Navigate to invoice details screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 