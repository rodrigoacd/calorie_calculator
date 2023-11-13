"""
Utilidades de nutrición
Funciones auxiliares para cálculos nutricionales
"""

def calculate_macros(calories, diet_type='balanced'):
    """
    Calcula la distribución de macronutrientes
    
    Args:
        calories (float): Calorías totales diarias
        diet_type (str): Tipo de dieta ('balanced', 'high_protein', 'low_carb')
    
    Returns:
        dict: Gramos de proteína, carbohidratos y grasas
    """
    macro_distributions = {
        'balanced': {'protein': 0.30, 'carbs': 0.40, 'fats': 0.30},
        'high_protein': {'protein': 0.40, 'carbs': 0.30, 'fats': 0.30},
        'low_carb': {'protein': 0.35, 'carbs': 0.20, 'fats': 0.45}
    }
    
    if diet_type not in macro_distributions:
        raise ValueError(f"Tipo de dieta inválido. Usa: {', '.join(macro_distributions.keys())}")
    
    distribution = macro_distributions[diet_type]
    
    # Calorías por gramo: Proteína = 4, Carbohidratos = 4, Grasas = 9
    protein_grams = (calories * distribution['protein']) / 4
    carbs_grams = (calories * distribution['carbs']) / 4
    fats_grams = (calories * distribution['fats']) / 9
    
    return {
        'protein': round(protein_grams, 1),
        'carbs': round(carbs_grams, 1),
        'fats': round(fats_grams, 1)
    }


def bmi_category(weight, height):
    """
    Calcula el Índice de Masa Corporal (BMI) y su categoría
    
    Args:
        weight (float): Peso en kilogramos
        height (float): Altura en centímetros
    
    Returns:
        dict: BMI y categoría
    """
    height_m = height / 100  # Convertir a metros
    bmi = weight / (height_m ** 2)
    
    if bmi < 18.5:
        category = "Bajo peso"
    elif 18.5 <= bmi < 25:
        category = "Peso normal"
    elif 25 <= bmi < 30:
        category = "Sobrepeso"
    else:
        category = "Obesidad"
    
    return {
        'bmi': round(bmi, 2),
        'category': category
    }


def water_intake(weight, activity_level='moderate'):
    """
    Calcula la ingesta recomendada de agua
    
    Args:
        weight (float): Peso en kilogramos
        activity_level (str): Nivel de actividad
    
    Returns:
        float: Litros de agua recomendados por día
    """
    # Base: 30-35 ml por kg de peso corporal
    base_water = weight * 0.033  # Litros
    
    activity_multipliers = {
        'sedentary': 1.0,
        'light': 1.1,
        'moderate': 1.2,
        'active': 1.3,
        'very_active': 1.5
    }
    
    multiplier = activity_multipliers.get(activity_level, 1.0)
    
    return round(base_water * multiplier, 2)
