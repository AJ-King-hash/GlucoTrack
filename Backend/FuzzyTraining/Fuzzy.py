import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl

class FuzzySystem:
    def __init__(self):
        # 1. تعريف المتغيرات (Input & Output)
        gl = ctrl.Antecedent(np.arange(0, 251, 1), 'glycemic_load')
        activity = ctrl.Antecedent(np.arange(0, 11, 1), 'physical_activity') 
        hba1c = ctrl.Consequent(np.arange(4, 13, 0.1), 'hba1c')

        # 2. تعريف الدوال العضوية (Membership Functions)
        activity['low'] = fuzz.trapmf(activity.universe, [0, 0, 2, 4])
        activity['medium'] = fuzz.trimf(activity.universe, [3, 5, 7])
        activity['high'] = fuzz.trapmf(activity.universe, [6, 8, 10, 10])

        gl['low'] = fuzz.trapmf(gl.universe, [0, 0, 70, 100])
        gl['medium'] = fuzz.trimf(gl.universe, [80, 120, 160])
        gl['high'] = fuzz.trapmf(gl.universe, [140, 180, 250, 250])
        
        hba1c['healthy'] = fuzz.trimf(hba1c.universe, [4, 5, 5.7])
        hba1c['pre_diabetic'] = fuzz.trimf(hba1c.universe, [5.7, 6, 6.4])
        hba1c['diabetic'] = fuzz.trapmf(hba1c.universe, [6.5, 8, 12, 12])

        # 3. توسيع القواعد الضبابية (10 Rules)
        rules = [
            # حالات الحمل الجلايسيمي العالي (High GL)
            ctrl.Rule(gl['high'] & activity['low'], hba1c['diabetic']),          # 1. خطر مرتفع جداً
            ctrl.Rule(gl['high'] & activity['medium'], hba1c['diabetic']),       # 2. استهلاك عالي مع نشاط غير كافٍ
            ctrl.Rule(gl['high'] & activity['high'], hba1c['pre_diabetic']),     # 3. النشاط العالي يخفف أثر السكر العالي

            # حالات الحمل الجلايسيمي المتوسط (Medium GL)
            ctrl.Rule(gl['medium'] & activity['low'], hba1c['diabetic']),        # 4. حتى الأكل المتوسط مع خمول قد يؤدي للسكري
            ctrl.Rule(gl['medium'] & activity['medium'], hba1c['pre_diabetic']), # 5. حالة متوسطة عامة
            ctrl.Rule(gl['medium'] & activity['high'], hba1c['healthy']),        # 6. نشاط عالي يوازن الأكل المتوسط

            # حالات الحمل الجلايسيمي المنخفض (Low GL)
            ctrl.Rule(gl['low'] & activity['low'], hba1c['pre_diabetic']),       # 7. أكل جيد لكن الخمول الشديد يرفع الخطر قليلاً
            ctrl.Rule(gl['low'] & activity['medium'], hba1c['healthy']),         # 8. نمط حياة صحي جداً
            ctrl.Rule(gl['low'] & activity['high'], hba1c['healthy']),           # 9. الحالة المثالية للرياضيين

            # قاعدة إضافية للحالات الحرجة (Edge Case)
            ctrl.Rule(gl['high'] | (gl['medium'] & activity['low']), hba1c['diabetic']) # 10. تغطية إضافية لضمان عدم إغفال الخطر
        ]

        # إنشاء نظام التحكم
        self.hba1c_ctrl = ctrl.ControlSystem(rules)
        self.control_sim = ctrl.ControlSystemSimulation(self.hba1c_ctrl)

# التشغيل
fuzzy_sim = FuzzySystem().control_sim