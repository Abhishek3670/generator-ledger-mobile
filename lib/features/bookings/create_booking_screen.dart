import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'providers/booking_provider.dart';
import '../vendors/providers/vendor_provider.dart';
import '../generators/providers/generator_provider.dart';
import '../../core/models/vendor.dart';
import 'widgets/vendor_autocomplete.dart';
import 'widgets/assignment_method_toggle.dart';
import 'widgets/capacity_selector.dart';
import 'widgets/generator_dropdown.dart';
import 'widgets/date_chips_picker.dart';
import 'widgets/vendor_bookings_preview.dart';
import 'widgets/booking_success_sheet.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  int _currentStep = 0;
  
  Vendor? _selectedVendor;
  AssignmentMethod _assignmentMethod = AssignmentMethod.capacity;
  int? _selectedCapacity;
  String? _selectedGeneratorId;
  List<DateTime> _selectedDates = [];
  final TextEditingController _remarksController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<VendorProvider>().ensureVendorsLoaded();
        context.read<GeneratorProvider>().fetchGenerators();
      }
    });
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  List<int> _deriveCapacities() {
    final generators = context.read<GeneratorProvider>().generators;
    final Set<int> capacities = {};
    for (var g in generators) {
      if (g.inventoryType == 'retailer' || g.inventoryType == 'emergency') {
        capacities.add(g.capacity);
      }
    }
    final sorted = capacities.toList()..sort();
    return sorted;
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedVendor == null) {
      _showError('Please select a vendor.');
      return;
    }
    if (_currentStep == 1) {
      if (_assignmentMethod == AssignmentMethod.capacity && _selectedCapacity == null) {
        _showError('Please select a capacity.');
        return;
      }
      if (_assignmentMethod == AssignmentMethod.specificGenerator && _selectedGeneratorId == null) {
        _showError('Please select a specific generator.');
        return;
      }
    }
    if (_currentStep == 2 && _selectedDates.isEmpty) {
      _showError('Please select at least one date slot.');
      return;
    }
    
    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final provider = context.read<BookingProvider>();

    try {
      final items = _selectedDates.map((d) {
        return {
          if (_assignmentMethod == AssignmentMethod.specificGenerator)
            'generator_id': _selectedGeneratorId,
          if (_assignmentMethod == AssignmentMethod.capacity)
            'capacity_kva': _selectedCapacity,
          'date': DateFormat('yyyy-MM-dd').format(d),
          'remarks': _remarksController.text.trim(),
        };
      }).toList();

      final result = await provider.createBooking(
        vendorId: _selectedVendor!.id,
        items: items,
      );

      if (mounted) {
        if (result['error_code'] == 'retailer_out_of_stock') {
          final affectedDates = result['affected_dates'] as List<dynamic>? ?? [];
          _showEmergencyFallbackSheet(affectedDates);
        } else if (result.containsKey('booking_id') || result.containsKey('id')) {
          final bookingId = result['booking_id'] ?? result['id'] ?? 'Unknown ID';
          _showSuccessSheet(bookingId);
        } else {
          _showError('Unknown response format.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(provider.error ?? e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSheet(String bookingId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (ctx) => BookingSuccessSheet(
        bookingId: bookingId,
        onViewDetails: () {}, // navigation handled in sheet
      ),
    );
  }

  void _showEmergencyFallbackSheet(List<dynamic> affectedDates) {
    List<Map<String, String>> selectedEmergencies = affectedDates.map((act) {
       return {
          'date': act['date'].toString(),
          'generator_id': act['suggested_generator_id']?.toString() ?? '',
       };
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
         return StatefulBuilder(
           builder: (context, setStateModal) {
             return DraggableScrollableSheet(
               initialChildSize: 0.8,
               maxChildSize: 0.9,
               minChildSize: 0.5,
               expand: false,
               builder: (_, scrollController) {
                 return Column(
                   children: [
                     Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           const Text('Retailer Out Of Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                           IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                         ],
                       ),
                     ),
                     const Padding(
                       padding: EdgeInsets.symmetric(horizontal: 16.0),
                       child: Text('Retailer stock is unavailable for some dates. You can select an available emergency alternative below.', style: TextStyle(fontSize: 14)),
                     ),
                     const SizedBox(height: 16),
                     Expanded(
                       child: ListView.builder(
                         controller: scrollController,
                         itemCount: affectedDates.length,
                         itemBuilder: (context, index) {
                           final item = affectedDates[index];
                           final date = item['date'] ?? '';
                           final reqCap = item['capacity_kva']?.toString() ?? '-';
                           final suggGen = item['suggested_generator_id'];
                           final List<dynamic> options = item['emergency_options'] ?? [];
                           
                           final currentSelected = selectedEmergencies.firstWhere((e) => e['date'] == date)['generator_id'];

                           return Card(
                             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                             color: const Color(0xFFFFF1F2),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFFECDD3))),
                             child: Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('Date: $date', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                   Text('Requested Capacity: $reqCap kVA'),
                                   const SizedBox(height: 12),
                                   const Text('Suggested Generator:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.red)),
                                   Text('$suggGen', style: const TextStyle(fontWeight: FontWeight.bold)),
                                   const SizedBox(height: 16),
                                   const Text('Available Alternatives:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.red)),
                                   ...options.map((opt) {
                                      final gId = opt['generator_id']?.toString() ?? '';
                                      final cKva = opt['capacity_kva']?.toString() ?? '';
                                      final iden = opt['identification']?.toString() ?? '';
                                      final type = opt['type']?.toString() ?? '';
                                      return RadioListTile<String>(
                                        value: gId,
                                        groupValue: currentSelected,
                                        title: Text('$gId ($cKva kVA)'),
                                        subtitle: Text('$iden | $type', style: const TextStyle(fontSize: 12)),
                                        activeColor: Colors.red,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (val) {
                                          setStateModal(() {
                                            selectedEmergencies.firstWhere((e) => e['date'] == date)['generator_id'] = val!;
                                          });
                                        },
                                      );
                                   }),
                                 ],
                               ),
                             )
                           );
                         }
                       ),
                     ),
                     Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Row(
                         children: [
                           Expanded(
                             child: OutlinedButton(
                               onPressed: () => Navigator.pop(ctx),
                               child: const Text('Cancel'),
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: ElevatedButton(
                               onPressed: () {
                                 Navigator.pop(ctx);
                                 _submitWithEmergency(selectedEmergencies);
                               },
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                               child: const Text('Accept Fallback', style: TextStyle(color: Colors.white)),
                             ),
                           ),
                         ],
                       ),
                     )
                   ],
                 );
               }
             );
           }
         );
      }
    );
  }

  Future<void> _submitWithEmergency(List<Map<String, String>> selectedEmergencies) async {
    setState(() => _isSubmitting = true);
    final provider = context.read<BookingProvider>();
    
    final Map<String, String> emergencyOverrides = {};
    for (var act in selectedEmergencies) {
      if (act['date'] != null && act['generator_id'] != null) {
        emergencyOverrides[act['date']!] = act['generator_id']!;
      }
    }

    try {
      final items = _selectedDates.map((d) {
        final dateStr = DateFormat('yyyy-MM-dd').format(d);
        final overrideGen = emergencyOverrides[dateStr];
        
        return {
          if (overrideGen != null) 'generator_id': overrideGen
          else if (_assignmentMethod == AssignmentMethod.specificGenerator) 'generator_id': _selectedGeneratorId
          else 'capacity_kva': _selectedCapacity,
          'date': dateStr,
          'remarks': _remarksController.text.trim(),
        };
      }).toList();

      final result = await provider.createBooking(
        vendorId: _selectedVendor!.id,
        items: items,
      );

      if (mounted) {
        if (result != null && result['error_code'] == 'retailer_out_of_stock') {
          _showError('Still out of stock on emergency generators? Try different dates.');
        } else if (result != null && (result.containsKey('booking_id') || result.containsKey('id'))) {
          final bookingId = result['booking_id'] ?? result['id'] ?? 'Unknown ID';
          _showSuccessSheet(bookingId);
        } else {
          _showError('Unknown response format.');
        }
      }
    } catch (e) {
      if (mounted) _showError(provider.error ?? e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Create Booking'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        onStepTapped: (step) {
          // Allow tapping back to previous steps, but prevent skipping ahead
          if (step < _currentStep) {
             setState(() => _currentStep = step);
          } else {
             // to jump ahead, must validate nextStep progressively
             if (step == _currentStep + 1) _nextStep();
          }
        },
        controlsBuilder: (context, details) {
           return Padding(
             padding: const EdgeInsets.only(top: 24.0),
             child: Row(
               children: [
                 if (_currentStep < 3)
                   ElevatedButton(
                     onPressed: details.onStepContinue,
                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                     child: Text('Continue', style: const TextStyle(color: Colors.white)),
                   )
                 else
                   ElevatedButton(
                     onPressed: _isSubmitting ? null : details.onStepContinue,
                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                     child: _isSubmitting 
                     ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                     : const Text('Submit Booking', style: TextStyle(color: Colors.white)),
                   ),
                 const SizedBox(width: 16),
                 if (_currentStep > 0)
                   TextButton(
                     onPressed: details.onStepCancel,
                     child: const Text('Back', style: TextStyle(color: Color(0xFF64748B))),
                   ),
               ],
             ),
           );
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.indexed : StepState.editing,
            title: const Text('Vendor Selection', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 VendorAutocomplete(
                   initialVendor: _selectedVendor,
                   onSelected: (v) => setState(() => _selectedVendor = v),
                 ),
                 const SizedBox(height: 16),
                 AnimatedSize(
                   duration: const Duration(milliseconds: 300),
                   child: VendorBookingsPreview(
                     vendorId: _selectedVendor?.id,
                   ),
                 ),
              ],
            ),
          ),
          Step(
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.indexed : _currentStep == 1 ? StepState.editing : StepState.disabled,
            title: const Text('Generator Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssignmentMethodToggle(
                  selectedMethod: _assignmentMethod,
                  onChanged: (m) => setState(() => _assignmentMethod = m),
                ),
                const SizedBox(height: 16),
                AnimatedCrossFade(
                  firstChild: CapacitySelector(
                    selectedCapacity: _selectedCapacity,
                    capacities: _deriveCapacities(),
                    onSelected: (c) => setState(() => _selectedCapacity = c),
                  ),
                  secondChild: GeneratorDropdown(
                    selectedGeneratorId: _selectedGeneratorId,
                    onChanged: (id) =>
                        setState(() => _selectedGeneratorId = id),
                  ),
                  crossFadeState: _assignmentMethod == AssignmentMethod.capacity
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
          Step(
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.indexed : _currentStep == 2 ? StepState.editing : StepState.disabled,
            title: const Text('Dates & Remarks', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateChipsPicker(
                  selectedDates: _selectedDates,
                  onDatesChanged: (d) => setState(() => _selectedDates = d),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Optional Remarks',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0F172A)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Step(
            isActive: _currentStep >= 3,
            state: _currentStep == 3 ? StepState.editing : StepState.disabled,
            title: const Text('Draft Preview', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0))
               ),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text('Draft booking ready for submission.', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                     const SizedBox(height: 16),
                     Text('Vendor: ${_selectedVendor?.name} (${_selectedVendor?.id})'),
                     const SizedBox(height: 8),
                     if (_assignmentMethod == AssignmentMethod.capacity)
                       Text('Assignment: Capacity ${_selectedCapacity} kVA')
                     else
                       Text('Assignment: specific generator ${_selectedGeneratorId}'),
                     const SizedBox(height: 8),
                     Text('Dates: ${_selectedDates.map((d) => DateFormat('yyyy-MM-dd').format(d)).join(', ')}'),
                     if (_remarksController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Remarks: ${_remarksController.text}'),
                     ]
                  ],
               ),
            ),
          ),
        ],
      ),
    );
  }
}
