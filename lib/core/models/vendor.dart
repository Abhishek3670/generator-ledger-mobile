class Vendor {
  final String id;
  final String name;
  final String place;
  final String phone;

  Vendor({
    required this.id,
    required this.name,
    required this.place,
    required this.phone,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      place: json['place'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'place': place,
      'phone': phone,
    };
  }
}

class RentalVendor {
  final String rentalVendorId;
  final String name;
  final String place;
  final String phone;

  RentalVendor({
    required this.rentalVendorId,
    required this.name,
    required this.place,
    required this.phone,
  });

  factory RentalVendor.fromJson(Map<String, dynamic> json) {
    return RentalVendor(
      rentalVendorId: json['rental_vendor_id'],
      name: json['name'],
      place: json['place'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_vendor_id': rentalVendorId,
      'name': name,
      'place': place,
      'phone': phone,
    };
  }
}
