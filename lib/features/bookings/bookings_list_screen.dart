import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/booking_provider.dart';
import '../vendors/providers/vendor_provider.dart';
import '../../core/auth/permission_service.dart';
import '../../shared/widgets/search_bar.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_form.dart';
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

  @override
  Widget build(BuildContext context) {
    final canCreate =
        context.read<PermissionService>().can('booking_create_update');

    return Scaffold(
      appBar: const CorporateAppBar(
        title: 'Bookings',
      ),
      body: Consumer<VendorProvider>(
        builder: (context, vendorProvider, child) {
          return Column(
            children: [
              DirectorySearchBar(
                hintText: 'Search by ID or Vendor...',
                onChanged: (v) => setState(() => _searchQuery = v),
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

                    final filtered = provider.bookings.where((b) {
                      final q = _searchQuery.toLowerCase();
                      final vName = vendorProvider
                          .resolveVendorName(b.vendorId)
                          .toLowerCase();
                      return b.id.toLowerCase().contains(q) ||
                          vName.contains(q);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const EmptyState(
                        message: 'No bookings found',
                        subMessage:
                            'Try a different search or add a new booking.',
                      );
                    }

                    // Group bookings by Vendor Name
                    final Map<String, List<Booking>> groupedBookings = {};
                    for (var booking in filtered) {
                      final vName = vendorProvider.resolveVendorName(booking.vendorId);
                      if (!groupedBookings.containsKey(vName)) {
                        groupedBookings[vName] = [];
                      }
                      groupedBookings[vName]!.add(booking);
                    }

                    final vendorNames = groupedBookings.keys.toList()..sort();

                    return RefreshIndicator(
                      onRefresh: () async {
                        await provider.fetchBookings();
                        await vendorProvider.ensureVendorsLoaded();
                      },
                      child: ListView.builder(
                        itemCount: vendorNames.length,
                        itemBuilder: (context, index) {
                          final vendorName = vendorNames[index];
                          final vendorBookings = groupedBookings[vendorName]!;

                          return ExpansionTile(
                            initiallyExpanded: true,
                            title: Text(
                              vendorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            subtitle: Text(
                              '${vendorBookings.length} Active Booking${vendorBookings.length == 1 ? '' : 's'}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            children: vendorBookings.map((booking) {
                              return BookingCard(booking: booking);
                            }).toList(),
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
          ? FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const BookingForm(),
              ),
              tooltip: 'Add new booking',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
