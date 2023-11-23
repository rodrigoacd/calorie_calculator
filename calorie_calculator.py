"""
Calculadora de Calorías
Calcula las calorías diarias requeridas basándose en edad, peso, altura y nivel de actividad
"""

class CalorieCalculator:
    """Clase principal para calcular calorías diarias"""
    
    def __init__(self, age, weight, height, gender):
        """
        Inicializa el calculador de calorías
        
        Args:
            age (int): Edad en años
            weight (float): Peso en kilogramos
            height (float): Altura en centímetros
            gender (str): 'male' o 'female'
        """
        self.age = age
        self.weight = weight
        self.height = height
        self.gender = gender.lower()
    
    def calculate_water_intake(self, activity_level='moderate'):
        """
        FEATURE-Y: Calcula la ingesta diaria recomendada de agua
        
        Args:
            activity_level (str): Nivel de actividad
        
        Returns:
            float: Litros de agua recomendados
        """
        base_water = self.weight * 0.033
        activity_multipliers = {
            'sedentary': 1.0,
            'light': 1.1,
            'moderate': 1.2,
            'active': 1.3,
            'very_active': 1.5
        }
        multiplier = activity_multipliers.get(activity_level, 1.0)
        return round(base_water * multiplier, 2)
    
    def calculate_bmr(self):
        """
        Calcula la Tasa Metabólica Basal (BMR) usando la fórmula de Harris-Benedict
        
        Returns:
            float: BMR en calorías
        """
        if self.gender == 'male':
            bmr = 88.362 + (13.397 * self.weight) + (4.799 * self.height) - (5.677 * self.age)
        elif self.gender == 'female':
            bmr = 447.593 + (9.247 * self.weight) + (3.098 * self.height) - (4.330 * self.age)
        else:
            raise ValueError("El género debe ser 'male' o 'female'")
        
        return round(bmr, 2)
    
    def calculate_tdee(self, activity_level):
        """
        Calcula el Gasto Energético Diario Total (TDEE)
        
        Args:
            activity_level (str): Nivel de actividad
                - 'sedentary': Poco o ningún ejercicio
                - 'light': Ejercicio ligero 1-3 días/semana
                - 'moderate': Ejercicio moderado 3-5 días/semana
                - 'active': Ejercicio intenso 6-7 días/semana
                - 'very_active': Ejercicio muy intenso, trabajo físico
        
        Returns:
            float: TDEE en calorías
        """
        activity_multipliers = {
            'sedentary': 1.2,
            'light': 1.375,
            'moderate': 1.55,
            'active': 1.725,
            'very_active': 1.9
        }
        
        if activity_level not in activity_multipliers:
            raise ValueError(f"Nivel de actividad inválido. Usa: {', '.join(activity_multipliers.keys())}")
        
        bmr = self.calculate_bmr()
        tdee = bmr * activity_multipliers[activity_level]
        
        return round(tdee, 2)
    
    def calories_for_goal(self, goal, activity_level='moderate'):
        """
        Calcula calorías recomendadas según el objetivo
        
        Args:
            goal (str): Objetivo ('lose', 'maintain', 'gain')
            activity_level (str): Nivel de actividad
        
        Returns:
            dict: Calorías recomendadas y detalles
        """
        tdee = self.calculate_tdee(activity_level)
        
        if goal == 'lose':
            # Déficit de 500 calorías para perder ~0.5kg/semana
            calories = tdee - 500
            description = "Pérdida de peso (déficit de 500 cal)"
        elif goal == 'maintain':
            calories = tdee
            description = "Mantenimiento de peso"
        elif goal == 'gain':
            # Superávit de 500 calorías para ganar ~0.5kg/semana
            calories = tdee + 500
            description = "Ganancia de peso (superávit de 500 cal)"
        else:
            raise ValueError("El objetivo debe ser 'lose', 'maintain' o 'gain'")
        
        return {
            'bmr': self.calculate_bmr(),
            'tdee': tdee,
            'recommended_calories': round(calories, 2),
            'goal': description
        }


def main():
    """Función principal para demostración"""
    print("=" * 50)
    print("CALCULADORA DE CALORÍAS")
    print("=" * 50)
    
    # Ejemplo de uso
    calculator = CalorieCalculator(age=30, weight=70, height=175, gender='male')
    
    print(f"\nDatos del usuario:")
    print(f"  Edad: {calculator.age} años")
    print(f"  Peso: {calculator.weight} kg")
    print(f"  Altura: {calculator.height} cm")
    print(f"  Género: {calculator.gender}")
    
    print(f"\nIngesta de agua recomendada: {calculator.calculate_water_intake('moderate')} litros/día")
    print(f"Tasa Metabólica Basal (BMR): {calculator.calculate_bmr()} calorías/día")
    
    print("\nGasto Energético Diario Total (TDEE) por nivel de actividad:")
    for level in ['sedentary', 'light', 'moderate', 'active', 'very_active']:
        tdee = calculator.calculate_tdee(level)
        print(f"  {level}: {tdee} calorías/día")
    
    print("\nRecomendaciones según objetivo:")
    for goal in ['lose', 'maintain', 'gain']:
        result = calculator.calories_for_goal(goal, 'moderate')
        print(f"\n  {goal.upper()}:")
        print(f"    BMR: {result['bmr']} cal")
        print(f"    TDEE: {result['tdee']} cal")
        print(f"    Recomendación: {result['recommended_calories']} cal/día")
        print(f"    ({result['goal']})")


if __name__ == "__main__":
    main()
