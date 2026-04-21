import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/booking_provider.dart';
import '../vendors/providers/vendor_provider.dart';
import '../../core/auth/permission_service.dart';
import '../../core/api/api_client.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/state_widgets.dart';
import '../../widgets/shared/corporate_app_bar.dart';
import 'models/booking.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'all';
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<BookingProvider>().fetchBookings();
        context.read<VendorProvider>().ensureVendorsLoaded();
      }
    });
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF0F172A),
            colorScheme: const ColorScheme.light(primary: Color(0xFF0F172A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = 'all';
      _dateFrom = null;
      _dateTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canCreate =
        context.read<PermissionService>().can('booking_create_update');

    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CorporateAppBar(
        title: 'Bookings by Vendor',
      ),
      body: Consumer<VendorProvider>(
        builder: (context, vendorProvider, child) {
          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    DirectorySearchBar(
                      hintText: 'Search vendor, ID, status...',
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                                  DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedStatus = v);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDateRange(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _dateFrom != null && _dateTo != null
                                          ? '${dateFormat.format(_dateFrom!)} - ${dateFormat.format(_dateTo!)}'
                                          : 'Date Range',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_dateFrom != null || _selectedStatus != 'all' || _searchQuery.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<BookingProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.bookings.isEmpty) {
                      return const LoadingState(message: 'Loading bookings...');
                    }

                    if (provider.error != null && provider.bookings.isEmpty) {
                      return ErrorState(
                        message: provider.error!,
                        onRetry: () => provider.fetchBookings(),
                      );
                    }

                    if (provider.bookings.isEmpty) {
                      return const EmptyState(
                        message: 'No bookings found',
                        subMessage: 'Try adding a new booking.',
                      );
                    }

                    // Extract unique vendor IDs
                    final Set<String> vendorIds = {};
                    for (var b in provider.bookings) {
                      vendorIds.add(b.vendorId);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await provider.fetchBookings();
                        await vendorProvider.ensureVendorsLoaded();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: vendorIds.length,
                        itemBuilder: (context, index) {
                          final vId = vendorIds.elementAt(index);
                          final vName = vendorProvider.resolveVendorName(vId);

                          return VendorBookingsAccordion(
                            vendorId: vId,
                            vendorName: vName,
                            searchQuery: _searchQuery,
                            selectedStatus: _selectedStatus,
                            dateFrom: _dateFrom,
                            dateTo: _dateTo,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-booking'),
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}

class VendorBookingsAccordion extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String searchQuery;
  final String selectedStatus;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const VendorBookingsAccordion({
    super.key,
    required this.vendorId,
    required this.vendorName,
    required this.searchQuery,
    required this.selectedStatus,
    this.dateFrom,
    this.dateTo,
  });

  @override
  State<VendorBookingsAccordion> createState() => _VendorBookingsAccordionState();
}

class _VendorBookingsAccordionState extends State<VendorBookingsAccordion> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant VendorBookingsAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vendorId != widget.vendorId) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get('/api/vendors/${widget.vendorId}/bookings');
      if (mounted) {
        setState(() {
          _data = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    
    if (_data == null) {
       return const SizedBox.shrink();
    }

    final bookings = _data!['bookings'] as List<dynamic>? ?? [];
    
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
         DateTime? dt;
         try { dt = DateTime.parse(dateKey); } catch(_){}

         if (widget.dateFrom != null && dt != null && dt.isBefore(widget.dateFrom!.subtract(const Duration(days: 1)))) continue;
         if (widget.dateTo != null && dt != null && dt.isAfter(widget.dateTo!.add(const Duration(days: 1)))) continue;

         final st = item['item_status']?.toString() ?? bStatus;
         if (widget.selectedStatus != 'all' && st.toLowerCase() != widget.selectedStatus.toLowerCase()) continue;

         final genId = item['generator_id']?.toString() ?? '';
         final cap = item['capacity_kva']?.toString() ?? '';
         final rem = item['remarks']?.toString() ?? '';
         final invType = item['inventory_type']?.toString() ?? '';

         final q = widget.searchQuery.toLowerCase();
         if (q.isNotEmpty) {
            final textToSearch = '${widget.vendorName} $bId $dateKey $genId $cap $rem $st'.toLowerCase();
            if (!textToSearch.contains(q)) continue;
         }

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const Border(),
          title: Text(widget.vendorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
          subtitle: Text('${bookingBlocks.length} Bookings', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          children: bookingBlocks.map((block) => _buildBookingBlock(block)).toList(),
        ),
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
              color: const Color(0xFFF8FAFC),
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
           ...dateRows.map((r) => _buildRow(r, bId)).toList(),
        ],
     );
  }

  Widget _buildRow(Map<String, dynamic> row, String bookingId) {
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

     return InkWell(
       onTap: () => GoRouter.of(context).push('/bookings/$bookingId'),
       child: Container(
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
       )
     );
  }
}
