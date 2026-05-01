class InsulinExpertSystem:
    def __init__(self):
        self.hypothesis_cf = 0.0

    def combine_cf(self, cf1: float, cf2: float) -> float:
        if cf1 >= 0 and cf2 >= 0:
            return cf1 + cf2 - (cf1 * cf2)
        elif cf1 < 0 and cf2 < 0:
            return cf1 + cf2 + (cf1 * cf2)
        else:
            denominator = 1 - min(abs(cf1), abs(cf2))
            if denominator == 0:
                return 1.0 
            return (cf1 + cf2) / denominator

    def evaluate_patient_risk(self, mean_gl: float, bmi: float, has_genetic_disease: bool) -> float:
        current_cf = 0.0

        if mean_gl >= 20:
            rule1_cf = 0.8  
        elif mean_gl >= 10:
            rule1_cf = 0.4  
        else:
            rule1_cf = -0.6  
        
        current_cf = self.combine_cf(current_cf, rule1_cf)

        if bmi >= 30:
            rule2_cf = 0.6  
        elif bmi >= 25:
            rule2_cf = 0.3
        else:
            rule2_cf = -0.4 # وزن طبيعي ينفي الخطر نسبياً
            
        current_cf = self.combine_cf(current_cf, rule2_cf)

        # القاعدة 3: العامل الوراثي
        if has_genetic_disease:
            rule3_cf = 0.7
        else:
            rule3_cf = -0.2

        current_cf = self.combine_cf(current_cf, rule3_cf)

        return round(current_cf, 2)
        
    def get_risk_label(self, final_cf: float) -> str:
        """تحويل رقم اليقين إلى نص يمكن تخزينه في قاعدة البيانات"""
        if final_cf >= 0.6:
            return "High Risk / High Insulin Need"
        elif 0.2 <= final_cf < 0.6:
            return "Medium Risk"
        elif -0.2 <= final_cf < 0.2:
            return "Unknown / Stable"
        else:
            return "Low Risk / Healthy Response"

# إنشاء نسخة (Instance) لاستخدامها في التطبيق
expert_system = InsulinExpertSystem()