import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_state.dart';
import '../widgets/add_shipment_dialog.dart';
import '../widgets/shipment_card.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shipments = appState.filteredShipments;

    return Scaffold(
      appBar: AppBar(title: const Text('Shipments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => const AddShipmentDialog(),
              );

              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shipment created successfully'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Shipment'),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: appState.updateShipmentSearchQuery,
            decoration: const InputDecoration(
              hintText: 'Search by shipment ID or route',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: appState.shipmentStatusFilter == 'All',
                  onSelected: () => appState.updateShipmentStatusFilter('All'),
                ),
                _FilterChip(
                  label: 'In Transit',
                  selected: appState.shipmentStatusFilter == 'In Transit',
                  onSelected: () =>
                      appState.updateShipmentStatusFilter('In Transit'),
                ),
                _FilterChip(
                  label: 'Delayed',
                  selected: appState.shipmentStatusFilter == 'Delayed',
                  onSelected: () =>
                      appState.updateShipmentStatusFilter('Delayed'),
                ),
                _FilterChip(
                  label: 'At Risk',
                  selected: appState.shipmentStatusFilter == 'At Risk',
                  onSelected: () =>
                      appState.updateShipmentStatusFilter('At Risk'),
                ),
                _FilterChip(
                  label: 'Delivered',
                  selected: appState.shipmentStatusFilter == 'Delivered',
                  onSelected: () =>
                      appState.updateShipmentStatusFilter('Delivered'),
                ),
                _FilterChip(
                  label: 'Customs Delay',
                  selected: appState.shipmentStatusFilter == 'Customs Delay',
                  onSelected: () =>
                      appState.updateShipmentStatusFilter('Customs Delay'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (shipments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No shipments match the current search/filter.'),
              ),
            )
          else
            ...shipments.map(
              (shipment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShipmentCard(shipment: shipment),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
