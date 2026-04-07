import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl
# ولكن، يمكننا بناء نظام تنبؤي (Predictive System) يعتمد على تتبع الأحمال الجلايسيمية اليومية لفترة طويلة لتقدير السكر التراكمي المتوقع. إليك كيفية بناء هذا النظام تقنياً:
class FuzzySystem:
    def __init__(self):
        gl = ctrl.Antecedent(np.arange(0, 251, 1), 'glycemic_load')
        activity = ctrl.Antecedent(np.arange(0, 11, 1), 'physical_activity') # مقياس من 0 لـ 10
        hba1c = ctrl.Consequent(np.arange(4, 13, 0.1), 'hba1c')

        # 2. الدوال العضوية للنشاط البدني (خامل، متوسط، رياضي)
        activity['low'] = fuzz.trapmf(activity.universe, [0, 0, 2, 4])
        activity['medium'] = fuzz.trimf(activity.universe, [3, 5, 7])
        activity['high'] = fuzz.trapmf(activity.universe, [6, 8, 10, 10])

        # (نفس تعريفات GL و HbA1c السابقة)
        gl['low'] = fuzz.trapmf(gl.universe, [0, 0, 70, 100])
        gl['medium'] = fuzz.trimf(gl.universe, [80, 120, 160])
        gl['high'] = fuzz.trapmf(gl.universe, [140, 180, 250, 250])
        
        hba1c['healthy'] = fuzz.trimf(hba1c.universe, [4, 5, 5.7])
        hba1c['pre_diabetic'] = fuzz.trimf(hba1c.universe, [5.7, 6, 6.4])
        hba1c['diabetic'] = fuzz.trapmf(hba1c.universe, [6.5, 8, 12, 12])
        # 3. القواعد الضبابية المتقدمة (Logic Rules)
        rules = [
            # إذا كان الأكل سيئاً والخمول عالياً -> النتيجة سكري مؤكد
            ctrl.Rule(gl['high'] & activity['low'], hba1c['diabetic']),
            
            # إذا كان الأكل سيئاً لكن النشاط عالٍ -> النتيجة قد تنخفض لمرحلة ما قبل السكري
            ctrl.Rule(gl['high'] & activity['high'], hba1c['pre_diabetic']),
            
            # إذا كان الأكل متوسطاً والنشاط عالٍ -> النتيجة صحية
            ctrl.Rule(gl['medium'] & activity['high'], hba1c['healthy']),
            
            # إذا كان الأكل منخفضاً (جيد) -> النتيجة صحية بغض النظر عن النشاط
            ctrl.Rule(gl['low'], hba1c['healthy']),
            
            # حالة متوسطة
            ctrl.Rule(gl['medium'] & activity['medium'], hba1c['pre_diabetic'])
        ]
    # إنشاء نظام التحكم
        self.hba1c_ctrl = ctrl.ControlSystem(rules)
        self.control_sim= ctrl.ControlSystemSimulation(self.hba1c_ctrl)

fuzzy_sim = FuzzySystem().control_sim
