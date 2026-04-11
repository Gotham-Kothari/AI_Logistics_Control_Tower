import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_state.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/section_title.dart';
import '../widgets/shipment_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (!appState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final riskyShipments = appState.riskyShipments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ControlHub'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: appState.updateHomeSearchQuery,
            decoration: const InputDecoration(
              hintText: 'Search shipment, alert, route...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              MetricCard(
                title: 'Total Shipments',
                value: '${appState.totalShipmentsCount}',
                subtitle: 'All tracked shipments',
                icon: Icons.groups_outlined,
              ),
              MetricCard(
                title: 'On-Time Deliveries',
                value: '${appState.onTimeDeliveryPercentage}%',
                subtitle: 'Live calculated estimate',
                icon: Icons.show_chart,
              ),
              MetricCard(
                title: 'Active Shipments',
                value: '${appState.activeShipmentsCount}',
                subtitle: 'Not yet delivered',
                icon: Icons.inventory_2_outlined,
              ),
              MetricCard(
                title: 'High Risk Shipments',
                value: '${appState.highRiskShipmentsCount}',
                subtitle: 'Need close attention',
                icon: Icons.history_toggle_off,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Quick Actions'),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: QuickActionButton(
                  label: 'Add Shipment',
                  icon: Icons.add_box_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  label: 'Add Event',
                  icon: Icons.add_location_alt_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: QuickActionButton(
                  label: 'Get Suggestions',
                  icon: Icons.auto_awesome_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Shipments Requiring Attention'),
          const SizedBox(height: 12),
          if (riskyShipments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No matching shipments found.'),
              ),
            )
          else
            ...riskyShipments.map(
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
