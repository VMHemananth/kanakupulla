import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/credit_card_model.dart';
import '../../data/repositories/credit_card_repository.dart';

final creditCardProvider = StateNotifierProvider<CreditCardNotifier, AsyncValue<List<CreditCardModel>>>((ref) {
  final repository = ref.watch(creditCardRepositoryProvider);
  return CreditCardNotifier(repository);
});

class CreditCardNotifier extends StateNotifier<AsyncValue<List<CreditCardModel>>> {
  final CreditCardRepository _repository;

  CreditCardNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCreditCards();
  }

  Future<void> loadCreditCards() async {
    try {
      state = const AsyncValue.loading();
      final cards = await _repository.getCreditCards();
      state = AsyncValue.data(cards);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCreditCard(CreditCardModel card) async {
    try {
      await _repository.addCreditCard(card);
      await loadCreditCards();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateCreditCard(CreditCardModel card) async {
    try {
      await _repository.updateCreditCard(card);
      await loadCreditCards();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCreditCard(String id) async {
    try {
      await _repository.deleteCreditCard(id);
      await loadCreditCards();
    } catch (e) {
      // Handle error
    }
  }
}
