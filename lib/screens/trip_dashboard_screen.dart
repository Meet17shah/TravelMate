import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/trip_model.dart';
import '../providers/expense_provider.dart';
import '../providers/itinerary_provider.dart';
import '../providers/participant_provider.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)!.settings.arguments as Trip;

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Itinerary'),
            Tab(text: 'Expenses'),
            Tab(text: 'Balances'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(trip: trip),
          _ItineraryTab(trip: trip),
          _ExpensesTab(trip: trip),
          _BalancesTab(trip: trip),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          if (_tabController.index == 1) {
            return FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add-itinerary', arguments: trip.id),
              child: const Icon(Icons.event),
            );
          } else if (_tabController.index == 2) {
            return FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add-expense', arguments: trip.id),
              child: const Icon(Icons.add_shopping_cart),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Trip trip;
  const _OverviewTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    final expProv = Provider.of<ExpenseProvider>(context);
    final total = expProv.getTotalExpenses(trip.id);
    final partProv = Provider.of<ParticipantProvider>(context);
    final participants = partProv.getParticipantsForTrip(trip.id);
    final expMap = expProv.getExpensesByParticipant(trip.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppTheme.cardBg,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text('Total Spent'),
                Text(Formatters.formatCurrency(total), style: Theme.of(context).textTheme.displayLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (total > 0) ...[
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: expMap.entries.map((e) {
                  final p = participants.firstWhere((p) => p.id == e.key, orElse: () => participants[0]);
                  return PieChartSectionData(
                    value: e.value,
                    title: p.name,
                    color: Color(int.parse(p.avatarColorHex)),
                    radius: 50,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  final Trip trip;
  const _ItineraryTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    final itinProv = Provider.of<ItineraryProvider>(context);
    final grouped = itinProv.getItemsGroupedByDate(trip.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(Formatters.formatDate(entry.key), style: const TextStyle(color: AppTheme.highlight, fontWeight: FontWeight.bold)),
            ),
            ...entry.value.map((item) => ListTile(
              title: Text(item.activity),
              subtitle: Text(item.time ?? 'Anytime'),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => itinProv.deleteItem(item.id)),
            )),
          ],
        );
      }).toList(),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final Trip trip;
  const _ExpensesTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    final expProv = Provider.of<ExpenseProvider>(context);
    final expenses = expProv.getExpensesForTrip(trip.id);
    final partProv = Provider.of<ParticipantProvider>(context);
    final participants = partProv.getParticipantsForTrip(trip.id);

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final e = expenses[index];
        final payer = participants.firstWhere((p) => p.id == e.paidById, orElse: () => participants[0]);
        return ListTile(
          title: Text(e.description),
          subtitle: Text('Paid by ${payer.name}'),
          trailing: Text(Formatters.formatCurrency(e.amount), style: Theme.of(context).textTheme.labelLarge),
          onLongPress: () => expProv.deleteExpense(e.id),
        );
      },
    );
  }
}

class _BalancesTab extends StatelessWidget {
  final Trip trip;
  const _BalancesTab({required this.trip});

  @override
  Widget build(BuildContext context) {
    final expProv = Provider.of<ExpenseProvider>(context);
    final balances = expProv.calculateBalances(trip.id);
    final settlements = expProv.calculateSettlements(trip.id);
    final partProv = Provider.of<ParticipantProvider>(context);
    final participants = partProv.getParticipantsForTrip(trip.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Individual Balances', style: TextStyle(fontWeight: FontWeight.bold)),
        ...balances.entries.map((e) {
          final p = participants.firstWhere((p) => p.id == e.key);
          return ListTile(
            title: Text(p.name),
            trailing: Chip(
              label: Text(Formatters.formatCurrency(e.value)),
              backgroundColor: e.value >= 0 ? AppTheme.success.withOpacity(0.2) : AppTheme.highlight.withOpacity(0.2),
            ),
          );
        }),
        const Divider(),
        const Text('Suggested Settlements', style: TextStyle(fontWeight: FontWeight.bold)),
        ...settlements.map((s) {
          final from = participants.firstWhere((p) => p.id == s['from']);
          final to = participants.firstWhere((p) => p.id == s['to']);
          return ListTile(
            leading: const Icon(Icons.payment),
            title: Text('${from.name} pays ${to.name}'),
            trailing: Text(Formatters.formatCurrency(s['amount'])),
          );
        }),
      ],
    );
  }
}
