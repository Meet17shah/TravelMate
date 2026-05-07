import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip_model.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';
import 'gradient_card.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final totalExpense = expenseProvider.getTotalExpenses(trip.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientCard(
        onTap: () => Navigator.pushNamed(context, '/dashboard', arguments: trip),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(trip.name, style: Theme.of(context).textTheme.titleLarge),
                ),
                Text(
                  Formatters.formatCurrency(totalExpense),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(trip.destination, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${Formatters.formatDate(trip.startDate)} - ${Formatters.formatDate(trip.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('${trip.participantIds.length}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
