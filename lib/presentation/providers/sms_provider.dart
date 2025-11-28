import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/sms_service.dart';

final smsServiceProvider = Provider<SmsService>((ref) => SmsService());

final smsTransactionsProvider = FutureProvider<List<TransactionCandidate>>((ref) async {
  final service = ref.watch(smsServiceProvider);
  return service.getTransactionMessages();
});
