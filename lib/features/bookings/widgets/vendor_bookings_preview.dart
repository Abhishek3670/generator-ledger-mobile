import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_client.dart';

class VendorBookingsPreview extends StatefulWidget {
  final String? vendorId;
  const VendorBookingsPreview({super.key, this.vendorId});

  @override
  State<VendorBookingsPreview> createState() => _VendorBookingsPreviewState();
}

class _VendorBookingsPreviewState extends State<VendorBookingsPreview> {
  Map<String, dynamic>? _data;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPreview();
  }

  @override
  void didUpdateWidget(covariant VendorBookingsPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vendorId != widget.vendorId) {
      _fetchPreview();
    }
  }

  Future<void> _fetchPreview() async {
    if (widget.vendorId == null || widget.vendorId!.isEmpty) {
      if (mounted) setState(() { _data = null; _error = null; });
      return;
    }

    if (mounted) setState(() { _isLoading = true; _error = null; });

    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get('/api/vendors/${widget.vendorId!}/bookings');
      if (mounted) {
        setState(() {
          _data = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load vendor bookings';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vendorId == null || widget.vendorId!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
      );
    }

    if (_data == null) return const SizedBox.shrink();

    final bookings = _data!['bookings'] as List<dynamic>? ?? [];
    if (bookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No existing bookings for this vendor.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
      );
    }

    // Structure: List of Booking Blocks
    // Each Booking Block: { booking_id, status, created_at, visible_date_rows: [ { date, generators, statuses, isEmergency } ] }
    final List<Map<String, dynamic>> bookingBlocks = [];

    for (var b in bookings) {
      final bId = b['booking_id']?.toString() ?? '';
      final bStatus = b['status']?.toString() ?? 'Pending';
      final bCreatedAt = b['created_at']?.toString() ?? '';
      final items = b['items'] as List<dynamic>? ?? [];

      final Map<String, Map<String, dynamic>> groupedByDate = {};
      bool hasVisibleItems = false;

      for (var item in items) {
         final startDt = item['start_dt'] as String?;
         if (startDt == null) continue;
         
         final dateKey = startDt.split(' ')[0];
         final st = item['item_status']?.toString() ?? bStatus;
         final genId = item['generator_id']?.toString() ?? '';
         final cap = item['capacity_kva']?.toString() ?? '';
         final invType = item['inventory_type']?.toString() ?? '';

         hasVisibleItems = true;
         final genLabel = genId.isNotEmpty ? genId : '$cap kVA';

         if (!groupedByDate.containsKey(dateKey)) {
            groupedByDate[dateKey] = {
               'date': dateKey,
               'generators': <String>[],
               'statuses': <String>{},
               'isEmergency': false,
            };
         }

         groupedByDate[dateKey]!['generators'].add(genLabel);
         groupedByDate[dateKey]!['statuses'].add(st);
         if (invType == 'emergency') {
            groupedByDate[dateKey]!['isEmergency'] = true;
         }
      }

      if (hasVisibleItems) {
         final visibleDateRows = groupedByDate.values.toList()
           ..sort((a, b) => a['date'].compareTo(b['date']));
           
         bookingBlocks.add({
            'booking_id': bId,
            'status': bStatus,
            'created_at': bCreatedAt,
            'visible_date_rows': visibleDateRows,
         });
      }
    }

    if (bookingBlocks.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF334155), size: 20),
              const SizedBox(width: 8),
              Text(
                'Existing Bookings (${bookings.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Tip: Avoid selecting dates shown below to prevent overbooking.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Container(
             decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
             ),
             child: Column(
                children: bookingBlocks.map((block) => _buildBookingBlock(block)).toList(),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingBlock(Map<String, dynamic> block) {
     final String bId = block['booking_id'];
     final String bStatus = block['status'];
     final List<Map<String, dynamic>> dateRows = block['visible_date_rows'];
     
     Color bStatusColor = const Color(0xFF334155);
     Color bStatusBgColor = const Color(0xFFF1F5F9);
     final bStLower = bStatus.toLowerCase();
     if (bStLower.contains('confirmed')) { bStatusColor = const Color(0xFF15803D); bStatusBgColor = const Color(0xFFDCFCE7); }
     else if (bStLower.contains('pending')) { bStatusColor = const Color(0xFFB45309); bStatusBgColor = const Color(0xFFFEF3C7); }
     else if (bStLower.contains('cancelled')) { bStatusColor = const Color(0xFFBE123C); bStatusBgColor = const Color(0xFFFFE4E6); }

     return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                 border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))
              ),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text('Booking #$bId', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Container(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(color: bStatusBgColor, borderRadius: BorderRadius.circular(4)),
                       child: Text(bStatus, style: TextStyle(fontSize: 10, color: bStatusColor, fontWeight: FontWeight.w700)),
                    )
                 ],
              ),
           ),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             child: Row(
                children: [
                   Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.2))),
                   Expanded(flex: 2, child: Text('GENSET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.2))),
                   Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.2))),
                ],
             ),
           ),
           const Divider(height: 1, color: Color(0xFFE2E8F0)),
           ...dateRows.map((r) => _buildRow(r)).toList(),
        ],
     );
  }

  Widget _buildRow(Map<String, dynamic> row) {
     final bool isEmergency = row['isEmergency'];
     final Set<String> statuses = row['statuses'];
     
     final st = statuses.length == 1 ? statuses.first : statuses.join(' / ');
     final stLower = st.toLowerCase();
     
     Color statusColor = const Color(0xFF334155);
     Color statusBgColor = const Color(0xFFF1F5F9);
     if (stLower.contains('confirmed')) { statusColor = const Color(0xFF15803D); statusBgColor = const Color(0xFFDCFCE7); }
     else if (stLower.contains('pending')) { statusColor = const Color(0xFFB45309); statusBgColor = const Color(0xFFFEF3C7); }
     else if (stLower.contains('cancelled')) { statusColor = const Color(0xFFBE123C); statusBgColor = const Color(0xFFFFE4E6); }

     final genList = (row['generators'] as List<String>).join('\n');

     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
       decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
       ),
       child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Expanded(
               flex: 2,
               child: Text(row['date'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
             ),
             Expanded(
               flex: 2,
               child: Text(genList, style: TextStyle(fontSize: 13, fontWeight: isEmergency ? FontWeight.bold : FontWeight.normal, color: isEmergency ? Colors.red : const Color(0xFF334155))),
             ),
             Expanded(
               flex: 1,
               child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(4)),
                  child: Text(st, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
               ),
             ),
          ],
       ),
     );
  }
}
