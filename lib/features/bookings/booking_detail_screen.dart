import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/booking_provider.dart';
import '../vendors/providers/vendor_provider.dart';
import '../../core/auth/permission_service.dart';
import 'widgets/booking_item_edit_form.dart';
import '../../shared/widgets/state_widgets.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<BookingProvider>().fetchBookingDetails(widget.bookingId);
        context.read<VendorProvider>().ensureVendorsLoaded();
      }
    });
  }

  void _confirmCancel(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason for cancellation'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          TextButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              try {
                await context.read<BookingProvider>().cancelBooking(
                  widget.bookingId,
                  reasonController.text,
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                // Error handled by provider
              }
            },
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking entirely?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await context.read<BookingProvider>().deleteBooking(widget.bookingId);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                }
              } catch (e) {
                // Error handled by provider
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = context.read<PermissionService>();
    final canManage = permissionService.can('booking_create_update');
    final canDelete = permissionService.can('booking_delete');

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking ${widget.bookingId}'),
        actions: [
          if (canManage) ...[
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () {
                final provider = context.read<BookingProvider>();
                final data = provider.selectedBooking;
                if (data != null) {
                  showDialog(
                    context: context,
                    builder: (context) => BookingItemEditForm(
                      bookingId: widget.bookingId,
                      existingItems: data.items,
                    ),
                  );
                }
              },
              tooltip: 'Edit Items',
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => _confirmCancel(context),
              tooltip: 'Cancel Booking',
            ),
          ],
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Delete Booking',
            ),
        ],
      ),
      body: Consumer2<BookingProvider, VendorProvider>(
        builder: (context, provider, vendorProvider, child) {
          if (provider.isLoading && provider.selectedBooking == null) {
            return const LoadingState(message: 'Loading booking details...');
          }

          if (provider.error != null && provider.selectedBooking == null) {
            return ErrorState(
              message: provider.error!,
              onRetry: () => provider.fetchBookingDetails(widget.bookingId),
            );
          }

          final data = provider.selectedBooking;
          if (data == null) {
            return const EmptyState(
              message: 'Booking not found',
              subMessage: 'The requested booking may have been deleted or moved.',
              icon: Icons.search_off,
            );
          }

          final booking = data.booking;
          final items = data.items;
          final vendorName = vendorProvider.resolveVendorName(booking.vendorId);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(booking, vendorName),
              const SizedBox(height: 24),
              const Text(
                'Booking Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => _buildItemCard(item)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(booking, String vendorName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vendorName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Status: ${booking.status}'),
            Text('Created: ${DateFormat('MMM dd, yyyy HH:mm').format(booking.createdAt)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(item) {
    final isEmergency = item.inventoryType == 'emergency' || item.isEmergency;
    final color = isEmergency ? Colors.red : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.electric_bolt, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${item.capacityKva} kVA',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (isEmergency)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'EMERGENCY',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Generator: ${item.generatorId}'),
            Text(
              'Duration: ${DateFormat('MMM dd, HH:mm').format(item.startDt)} - ${DateFormat('MMM dd, HH:mm').format(item.endDt)}',
              style: const TextStyle(fontSize: 13),
            ),
            if (item.remarks != null && item.remarks!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Remarks: ${item.remarks}',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
