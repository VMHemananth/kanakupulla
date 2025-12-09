import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/debt_model.dart';
import '../providers/debt_provider.dart'; // Ensure this has updateDebt/AddPayment methods
import '../../core/utils/loan_calculator.dart';

class LoanDetailsScreen extends ConsumerStatefulWidget {
  final DebtModel debt;
  const LoanDetailsScreen({super.key, required this.debt});

  @override
  ConsumerState<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends ConsumerState<LoanDetailsScreen> {
  late DebtModel _debt;

  @override
  void initState() {
    super.initState();
    _debt = widget.debt;
  }

  @override
  Widget build(BuildContext context) {
    // Watch debt provider for updates
    final debtsAsync = ref.watch(debtProvider);
    debtsAsync.whenData((debts) {
      final updatedDebt = debts.firstWhere((d) => d.id == widget.debt.id, orElse: () => widget.debt);
      if (updatedDebt != _debt) {
        // Find existing to avoid setState during build if possible, but here we just update local ref
        // Actually best to rely on ConsumerWidget rebuilding. 
        // But since we are stateful, we can just use the provider value.
        _debt = updatedDebt; 
      }
    });

    final emi = LoanCalculator.calculateEMI(_debt.principalAmount, _debt.roi, _debt.tenureMonths);
    final totalInterest = (_debt.payments.fold(0.0, (sum, p) => sum + p.interestComponent));
    final totalPrincipalPaid = (_debt.payments.fold(0.0, (sum, p) => sum + p.principalComponent));
    
    // Future estimation
    final remainingTenure = LoanCalculator.calculateRemainingTenure(_debt.amount, _debt.roi, emi);
    final advice = LoanCalculator.getClosureAdvice(
      outstandingPrincipal: _debt.amount, 
      annualRoi: _debt.roi, 
      currentEMI: emi
    );

    return Scaffold(
      appBar: AppBar(title: Text('${_debt.personName} Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Outstanding Balance', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Text('₹${_debt.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('Principal', '₹${_debt.principalAmount.toStringAsFixed(0)}'),
                        _buildStat('ROI', '${_debt.roi}% ${_debt.interestType}'),
                        _buildStat('EMI', '₹${emi.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Charts (Pie Chart: Principal Paid vs Interest Paid vs Outstanding)
            if (_debt.payments.isNotEmpty) ...[
              const Text('Payment Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(color: Colors.green, value: totalPrincipalPaid, title: 'Prin Paid', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                      PieChartSectionData(color: Colors.orange, value: totalInterest, title: 'Int Paid', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                      PieChartSectionData(color: Colors.blue[200], value: _debt.amount, title: 'Remaining', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                    ],
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            
            // Financial Advice
            if (!_debt.isSettled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.lightbulb, color: Colors.amber), SizedBox(width: 8), Text('Financial Advice', style: TextStyle(fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 8),
                    Text(advice),
                    const SizedBox(height: 8),
                    Text('Est. Remaining Tenure: $remainingTenure months'),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay EMI'),
                    onPressed: () => _showPaymentDialog(context, emi, false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Part Payment'),
                    onPressed: () => _showPaymentDialog(context, 0, true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _debt.payments.length,
              itemBuilder: (context, index) {
                final payment = _debt.payments[index]; // Note: Should sort by date desc
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: payment.isPartPayment ? Colors.orange[100] : Colors.green[100],
                    child: Icon(payment.isPartPayment ? Icons.bolt : Icons.calendar_today, size: 16),
                  ),
                  title: Text('Paid ₹${payment.amount.toStringAsFixed(0)}'),
                  subtitle: Text('${DateFormat('dd MMM yyyy').format(payment.date)}\nPrin: ₹${payment.principalComponent.toStringAsFixed(0)} | Int: ₹${payment.interestComponent.toStringAsFixed(0)}'),
                  isThreeLine: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context, double defaultAmount, bool isPartPayment) {
     final controller = TextEditingController(text: defaultAmount > 0 ? defaultAmount.toStringAsFixed(0) : '');
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: Text(isPartPayment ? 'Make Part Payment' : 'Pay EMI'),
         content: TextField(
           controller: controller,
           keyboardType: TextInputType.number,
           decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
           ElevatedButton(
             onPressed: () {
               final amount = double.tryParse(controller.text);
               if (amount != null && amount > 0) {
                 _processPayment(amount, isPartPayment);
                 Navigator.pop(ctx);
               }
             },
             child: const Text('Confirm'),
           ),
         ],
       ),
     );
  }

  void _processPayment(double amount, bool isPartPayment) {
    ref.read(debtProvider.notifier).addPayment(_debt, amount, isPartPayment);
  }
}
