class MonitorData {
  final String timestamp;
  final CpuStats cpu;
  final MemoryStats memory;
  final TemperatureStats temperature;

  MonitorData({
    required this.timestamp,
    required this.cpu,
    required this.memory,
    required this.temperature,
  });

  factory MonitorData.fromJson(Map<String, dynamic> json) {
    return MonitorData(
      timestamp: json['timestamp'],
      cpu: CpuStats.fromJson(json['cpu']),
      memory: MemoryStats.fromJson(json['memory']),
      temperature: TemperatureStats.fromJson(json['temperature']),
    );
  }
}

class CpuStats {
  final double percent;
  final String status;

  CpuStats({required this.percent, required this.status});

  factory CpuStats.fromJson(Map<String, dynamic> json) {
    return CpuStats(
      percent: (json['percent'] as num).toDouble(),
      status: json['status'],
    );
  }
}

class MemoryStats {
  final double percent;
  final double usedMb;
  final double totalMb;
  final String status;

  MemoryStats({
    required this.percent,
    required this.usedMb,
    required this.totalMb,
    required this.status,
  });

  factory MemoryStats.fromJson(Map<String, dynamic> json) {
    return MemoryStats(
      percent: (json['percent'] as num).toDouble(),
      usedMb: (json['used_mb'] as num).toDouble(),
      totalMb: (json['total_mb'] as num).toDouble(),
      status: json['status'],
    );
  }
}

class TemperatureStats {
  final bool available;
  final double? celsius;
  final String? sensor;
  final String status;
  final String note;

  TemperatureStats({
    required this.available,
    this.celsius,
    this.sensor,
    required this.status,
    required this.note,
  });

  factory TemperatureStats.fromJson(Map<String, dynamic> json) {
    return TemperatureStats(
      available: json['available'],
      celsius: json['celsius'] != null ? (json['celsius'] as num).toDouble() : null,
      sensor: json['sensor'],
      status: json['status'],
      note: json['note'],
    );
  }
}

class CalendarEvent {
  final String title;
  final String start;
  final bool allDay;
  final CalendarExtendedProps extendedProps;

  CalendarEvent({
    required this.title,
    required this.start,
    required this.allDay,
    required this.extendedProps,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['title'],
      start: json['start'],
      allDay: json['allDay'],
      extendedProps: CalendarExtendedProps.fromJson(json['extendedProps']),
    );
  }
}

class CalendarExtendedProps {
  final String date;

  CalendarExtendedProps({required this.date});

  factory CalendarExtendedProps.fromJson(Map<String, dynamic> json) {
    return CalendarExtendedProps(
      date: json['date'],
    );
  }
}

class DayDetail {
  final String date;
  final List<VendorDayDetail> vendors;

  DayDetail({required this.date, required this.vendors});

  factory DayDetail.fromJson(Map<String, dynamic> json) {
    return DayDetail(
      date: json['date'],
      vendors: (json['vendors'] as List)
          .map((v) => VendorDayDetail.fromJson(v))
          .toList(),
    );
  }
}

class VendorDayDetail {
  final String vendorId;
  final String vendorName;
  final List<BookingDayDetail> bookings;

  VendorDayDetail({
    required this.vendorId,
    required this.vendorName,
    required this.bookings,
  });

  factory VendorDayDetail.fromJson(Map<String, dynamic> json) {
    return VendorDayDetail(
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
      bookings: (json['bookings'] as List)
          .map((b) => BookingDayDetail.fromJson(b))
          .toList(),
    );
  }
}

class BookingDayDetail {
  final String bookingId;
  final List<BookingItemDayDetail> items;

  BookingDayDetail({required this.bookingId, required this.items});

  factory BookingDayDetail.fromJson(Map<String, dynamic> json) {
    return BookingDayDetail(
      bookingId: json['booking_id'],
      items: (json['items'] as List)
          .map((i) => BookingItemDayDetail.fromJson(i))
          .toList(),
    );
  }
}

class BookingItemDayDetail {
  final String generatorId;
  final int? capacityKva;
  final String startDt;
  final String endDt;
  final String remarks;

  BookingItemDayDetail({
    required this.generatorId,
    this.capacityKva,
    required this.startDt,
    required this.endDt,
    required this.remarks,
  });

  factory BookingItemDayDetail.fromJson(Map<String, dynamic> json) {
    return BookingItemDayDetail(
      generatorId: json['generator_id'],
      capacityKva: json['capacity_kva'],
      startDt: json['start_dt'],
      endDt: json['end_dt'],
      remarks: json['remarks'],
    );
  }
}
