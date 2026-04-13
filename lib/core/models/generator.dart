class Generator {
  final String id;
  final int capacity;
  final String identification;
  final String type;
  final String status;
  final String? notes;
  final String inventoryType;
  final String? rentalVendorId;
  final String? rentalVendorName;
  final String? inventoryLabel;

  Generator({
    required this.id,
    required this.capacity,
    required this.identification,
    required this.type,
    required this.status,
    this.notes,
    required this.inventoryType,
    this.rentalVendorId,
    this.rentalVendorName,
    this.inventoryLabel,
  });

  factory Generator.fromJson(Map<String, dynamic> json) {
    return Generator(
      id: json['id'],
      capacity: json['capacity'] as int,
      identification: json['identification'],
      type: json['type'],
      status: json['status'],
      notes: json['notes'],
      inventoryType: json['inventory_type'],
      rentalVendorId: json['rental_vendor_id'],
      rentalVendorName: json['rental_vendor_name'],
      inventoryLabel: json['inventory_label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'capacity': capacity,
      'identification': identification,
      'type': type,
      'status': status,
      'notes': notes,
      'inventory_type': inventoryType,
      'rental_vendor_id': rentalVendorId,
      'rental_vendor_name': rentalVendorName,
      'inventory_label': inventoryLabel,
    };
  }
}
