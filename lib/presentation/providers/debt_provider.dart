import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/debt_model.dart';
import '../../data/repositories/debt_repository.dart';
import '../../core/utils/loan_calculator.dart';

final debtProvider = StateNotifierProvider<DebtNotifier, AsyncValue<List<DebtModel>>>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return DebtNotifier(repository);
});

class DebtNotifier extends StateNotifier<AsyncValue<List<DebtModel>>> {
  final DebtRepository _repository;

  DebtNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDebts();
  }

  Future<void> loadDebts() async {
    try {
      state = const AsyncValue.loading();
      final debts = await _repository.getDebts();
      state = AsyncValue.data(debts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDebt(DebtModel debt) async {
    try {
      await _repository.addDebt(debt);
      await loadDebts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateDebt(DebtModel debt) async {
    try {
      await _repository.updateDebt(debt);
      await loadDebts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteDebt(String id) async {
    try {
      await _repository.deleteDebt(id);
      await loadDebts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addPayment(DebtModel debt, double amount, bool isPartPayment) async {
      // Calculate components
      final components = LoanCalculator.calculatePaymentComponents(
        outstandingPrincipal: debt.amount, 
        paymentAmount: amount, 
        annualRoi: debt.roi, 
        lastPaymentDate: debt.payments.isNotEmpty ? debt.payments.last.date : debt.date, 
        currentPaymentDate: DateTime.now() 
      );

      final payment = LoanPayment(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        amount: amount, 
        date: DateTime.now(), 
        principalComponent: components['principal']!, 
        interestComponent: components['interest']!,
        isPartPayment: isPartPayment,
      );
      
      final newPayments = List<LoanPayment>.from(debt.payments)..add(payment);
      final newOutstanding = debt.amount - components['principal']!; 

      final updatedDebt = debt.copyWith(
        amount: newOutstanding,
        payments: newPayments,
        isSettled: newOutstanding <= 0,
      );

      await updateDebt(updatedDebt);
  }
}
