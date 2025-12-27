class BudgetRuleModel {
  final double needs;
  final double wants;
  final double savings;

  const BudgetRuleModel({
    required this.needs,
    required this.wants,
    required this.savings,
  });

  // Default factory
  factory BudgetRuleModel.defaultRule() {
    return const BudgetRuleModel(needs: 50, wants: 30, savings: 20);
  }

  // To/From Map for simple storage if needed (though we might store as individual keys)
  Map<String, dynamic> toMap() {
    return {
      'needs': needs,
      'wants': wants,
      'savings': savings,
    };
  }

  factory BudgetRuleModel.fromMap(Map<String, dynamic> map) {
    return BudgetRuleModel(
      needs: map['needs']?.toDouble() ?? 50.0,
      wants: map['wants']?.toDouble() ?? 30.0,
      savings: map['savings']?.toDouble() ?? 20.0,
    );
  }
}
