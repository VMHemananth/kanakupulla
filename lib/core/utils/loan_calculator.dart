import 'dart:math';

class LoanCalculator {
  /// Calculates EMI using the formula: E = P * r * (1+r)^n / ((1+r)^n - 1)
  /// [principal] - Loan Amount
  /// [annualRoi] - Rate of Interest (Annual %)
  /// [tenureMonths] - Loan Tenure in Months
  static double calculateEMI(double principal, double annualRoi, int tenureMonths) {
    if (annualRoi <= 0) return principal / tenureMonths;
    
    final monthlyRate = annualRoi / 12 / 100;
    final emi = (principal * monthlyRate * pow(1 + monthlyRate, tenureMonths)) /
        (pow(1 + monthlyRate, tenureMonths) - 1);
    
    return emi;
  }

  /// Estimates the remaining tenure if part payment is made or EMI is changed.
  /// Simplistic approach: Keep EMI same, reduce tenure.
  static int calculateRemainingTenure(double outstandingPrincipal, double annualRoi, double emi) {
    if (annualRoi <= 0) return (outstandingPrincipal / emi).ceil();
    
    final monthlyRate = annualRoi / 12 / 100;
    // Formula derived from EMI formula solving for n:
    // n = -log(1 - (P * r) / E) / log(1 + r)
    
    final denominator = log(1 + monthlyRate);
    final numeratorInner = 1 - (outstandingPrincipal * monthlyRate / emi);
    
    if (numeratorInner <= 0) return 0; // EMI < Interest? Infinite or error
    
    final numerator = -log(numeratorInner);
    return (numerator / denominator).ceil();
  }

  /// Calculates Principal and Interest components for a single payment.
  static Map<String, double> calculatePaymentComponents({
    required double outstandingPrincipal,
    required double paymentAmount,
    required double annualRoi,
    required DateTime lastPaymentDate,
    required DateTime currentPaymentDate,
  }) {
    // Interest is calculated on outstanding principal
    // Simple Interest for the period since last payment? Or monthly?
    // Usually loans calculate monthly interest.
    // Let's assume standard monthly compounding or daily. 
    // For simplicity and standard apps: Monthly rate applied if it's an EMI cycle.
    // But for part payments, we might want daily interest or just simple monthly proxy.
    
    // Let's stick to Monthly Rate * Principal for simplicity if gap is ~30 days.
    // If we want exactness: Interest = P * R * (Days / 365)
    
    final days = currentPaymentDate.difference(lastPaymentDate).inDays;
    // Avoid minimal days resulting in 0 interest if user pays next day
    final interestRate = annualRoi / 100;
    
    // Using Daily compounding for better accuracy on irregular dates
    final interest = outstandingPrincipal * interestRate * (days / 365.0);
    
    // Ensure we don't return negative interest
    final finalInterest = max(0.0, interest);
    
    // Principal component is whatever is left after paying interest
    var principalComp = paymentAmount - finalInterest;
    
    // If payment is less than interest, the principal component is negative (interest piles up)
    // or capped at paying off interest only? 
    // Usually unpaid interest adds to principal or is tracked separately.
    // For simplicity, we just return the calculation.
    
    return {
      'interest': finalInterest,
      'principal': principalComp,
    };
  }

  /// Generates advice string
  static String getClosureAdvice({
    required double outstandingPrincipal,
    required double annualRoi,
    required double currentEMI,
  }) {
    if (outstandingPrincipal <= 0) return "Loan fully paid.";
    
    // Example advice: "Paying 10% extra per month saves..."
    final extraPayment = currentEMI * 0.10;
    final totalInterestStandard = _calculateTotalInterest(outstandingPrincipal, annualRoi, currentEMI);
    final totalInterestAccelerated = _calculateTotalInterest(outstandingPrincipal, annualRoi, currentEMI + extraPayment);
    
    final savings = totalInterestStandard - totalInterestAccelerated;
    
    if (savings > 100) {
      return "Paying just ₹${extraPayment.toStringAsFixed(0)} extra per month could save you ₹${savings.toStringAsFixed(0)} in interest.";
    }
    return "You are on track to close this loan.";
  }
  
  static double _calculateTotalInterest(double principal, double roi, double emi) {
    if (roi <= 0) return 0;
    int tenure = calculateRemainingTenure(principal, roi, emi);
    double totalPaid = tenure * emi;
    return totalPaid - principal;
  }
}
