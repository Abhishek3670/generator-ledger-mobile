class Booking {
  final String id;
  final String vendorId;
  final String? vendorName;
  final DateTime createdAt;
  final String status;

  Booking({
    required this.id,
    required this.vendorId,
    this.vendorName,
    required this.createdAt,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }
}

class BookingItem {
  final int id;
  final String generatorId;
  final int? capacityKva;
  final String? inventoryType;
  final bool isEmergency;
  final DateTime startDt;
  final DateTime endDt;
  final String status;
  final String? remarks;

  BookingItem({
    required this.id,
    required this.generatorId,
    this.capacityKva,
    this.inventoryType,
    required this.isEmergency,
    required this.startDt,
    required this.endDt,
    required this.status,
    this.remarks,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'],
      generatorId: json['generator_id'],
      capacityKva: json['capacity_kva'],
      inventoryType: json['inventory_type'],
      isEmergency: json['is_emergency'] ?? false,
      startDt: DateTime.parse(json['start_dt']),
      endDt: DateTime.parse(json['end_dt']),
      status: json['status'],
      remarks: json['remarks'],
    );
  }
}

class BookingWithItems {
  final Booking booking;
  final List<BookingItem> items;

  BookingWithItems({required this.booking, required this.items});

  factory BookingWithItems.fromJson(Map<String, dynamic> json) {
    return BookingWithItems(
      booking: Booking.fromJson(json['booking']),
      items: (json['items'] as List)
          .map((i) => BookingItem.fromJson(i))
          .toList(),
    );
  }
}

class EmergencySuggestion {
  final int itemIndex;
  final String date;
  final int capacityKva;
  final String? suggestedGeneratorId;
  final List<EmergencyOption> emergencyOptions;

  EmergencySuggestion({
    required this.itemIndex,
    required this.date,
    required this.capacityKva,
    this.suggestedGeneratorId,
    required this.emergencyOptions,
  });

  factory EmergencySuggestion.fromJson(Map<String, dynamic> json) {
    return EmergencySuggestion(
      itemIndex: json['item_index'],
      date: json['date'],
      capacityKva: json['capacity_kva'],
      suggestedGeneratorId: json['suggested_generator_id'],
      emergencyOptions: (json['emergency_options'] as List)
          .map((o) => EmergencyOption.fromJson(o))
          .toList(),
    );
  }
}

class EmergencyOption {
  final String generatorId;
  final int capacityKva;
  final String identification;
  final String type;
  final String? notes;
  final String inventoryType;

  EmergencyOption({
    required this.generatorId,
    required this.capacityKva,
    required this.identification,
    required this.type,
    this.notes,
    required this.inventoryType,
  });

  factory EmergencyOption.fromJson(Map<String, dynamic> json) {
    return EmergencyOption(
      generatorId: json['generator_id'],
      capacityKva: json['capacity_kva'],
      identification: json['identification'],
      type: json['type'],
      notes: json['notes'],
      inventoryType: json['inventory_type'],
    );
  }
}
