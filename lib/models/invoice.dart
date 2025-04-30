class Invoice {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<InvoiceItem> items;
  final double subtotal;
  final double gstAmount;
  final double total;
  final DateTime date;
  final String status;
  final String? pdfUrl;

  Invoice({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.gstAmount,
    required this.total,
    required this.date,
    required this.status,
    this.pdfUrl,
  });

  factory Invoice.fromMap(String id, Map<String, dynamic> map) {
    return Invoice(
      id: id,
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      items: (map['items'] as List?)
              ?.map((item) => InvoiceItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      gstAmount: (map['gstAmount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      pdfUrl: map['pdfUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'gstAmount': gstAmount,
      'total': total,
      'date': Timestamp.fromDate(date),
      'status': status,
      'pdfUrl': pdfUrl,
    };
  }
}

class InvoiceItem {
  final String name;
  final String description;
  final double price;
  final int quantity;
  final double gstRate;

  InvoiceItem({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.gstRate,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      gstRate: (map['gstRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'gstRate': gstRate,
    };
  }

  double get total => price * quantity;
  double get gstAmount => total * (gstRate / 100);
  double get totalWithGst => total + gstAmount;
} 