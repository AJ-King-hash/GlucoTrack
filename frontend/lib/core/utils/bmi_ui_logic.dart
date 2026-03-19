// features/risk/presentation/manager/bmi_ui_logic.dart
class BmiUiLogic {
  static double calculateAlignment(double bmi) {
    const double minBmi = 15.0;
    const double maxBmi = 35.0;

    // Logic to map BMI to a 0.0 to 1.0 range for Alignment or Positioned
    double clampedBmi = bmi.clamp(minBmi, maxBmi);
    return (clampedBmi - minBmi) / (maxBmi - minBmi);
  }
}
