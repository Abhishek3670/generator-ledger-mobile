import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/booking_provider.dart';
import '../vendors/providers/vendor_provider.dart';
import '../../core/auth/permission_service.dart';
import '../../shared/widgets/search_bar.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_form.dart';

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
    final canCreate = context.read<PermissionService>().can('booking_create_update');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.error != null && provider.bookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${provider.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.fetchBookings(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final filtered = provider.bookings.where((b) {
                      final q = _searchQuery.toLowerCase();
                      final vName = vendorProvider.resolveVendorName(b.vendorId).toLowerCase();
                      return b.id.toLowerCase().contains(q) || vName.contains(q);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No bookings found'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await provider.fetchBookings();
                        await vendorProvider.ensureVendorsLoaded();
                      },
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final booking = filtered[index];
                          return BookingCard(booking: booking);
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
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
