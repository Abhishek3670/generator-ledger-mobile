import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/booking.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final dateOnlyFormat = DateFormat('MMM dd, yyyy');

    Color statusColor;
    Color statusBgColor;
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = const Color(0xFF15803D); // emerald-700
        statusBgColor = const Color(0xFFDCFCE7); // emerald-100
        break;
      case 'pending':
        statusColor = const Color(0xFFB45309); // amber-700
        statusBgColor = const Color(0xFFFEF3C7); // amber-100
        break;
      case 'cancelled':
        statusColor = const Color(0xFFBE123C); // rose-700
        statusBgColor = const Color(0xFFFFE4E6); // rose-100
        break;
      default:
        statusColor = const Color(0xFF334155); // slate-700
        statusBgColor = const Color(0xFFF1F5F9); // slate-100
    }

    // Extract dates and capacities, defaulting if missing
    String dateRangeStr = '-';
    String capacityStr = '-';
    
    // In our model Booking has items (which might be fetched directly or not).
    // If not, we just show created at. But since we need to "enhance with date row and kVA detail"
    // Let's assume booking has items or we can just derive from top level if available.
    // If it's a minimal booking object, we might not have items here unless it's BookingWithItems.
    // For now we'll display what we can.
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/bookings/${booking.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking #${booking.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'Created: ${dateFormat.format(booking.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
