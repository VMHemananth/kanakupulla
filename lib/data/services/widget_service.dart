import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String _appGroupId = 'group.kanakupulla'; // Not used for Android but good practice
  static const String _androidWidgetName = 'HomeWidgetProvider';

  Future<void> updateWidget(double balance) async {
    try {
      await HomeWidget.saveWidgetData<String>('balance', '₹${balance.toStringAsFixed(2)}');
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}
