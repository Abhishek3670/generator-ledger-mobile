class BillingLinesResponse {
  final String from;
  final String to;
  final List<BillingLineRow> rows;
  final List<int> capacities;
  final int count;

  BillingLinesResponse({
    required this.from,
    required this.to,
    required this.rows,
    required this.capacities,
    required this.count,
  });

  factory BillingLinesResponse.fromJson(Map<String, dynamic> json) {
    return BillingLinesResponse(
      from: json['from'],
      to: json['to'],
      rows: (json['rows'] as List)
          .map((row) => BillingLineRow.fromJson(row))
          .toList(),
      capacities: List<int>.from(json['capacities'] ?? []),
      count: json['count'],
    );
  }
}

class BillingLineRow {
  final String vendorId;
  final String vendorName;
  final String bookingId;
  final String bookedDate;
  final String generatorId;
  final int? capacityKva;
  final String inventoryType;

  BillingLineRow({
    required this.vendorId,
    required this.vendorName,
    required this.bookingId,
    required this.bookedDate,
    required this.generatorId,
    this.capacityKva,
    required this.inventoryType,
  });

  factory BillingLineRow.fromJson(Map<String, dynamic> json) {
    return BillingLineRow(
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
      bookingId: json['booking_id'],
      bookedDate: json['booked_date'],
      generatorId: json['generator_id'],
      capacityKva: json['capacity_kva'],
      inventoryType: json['inventory_type'],
    );
  }
}
