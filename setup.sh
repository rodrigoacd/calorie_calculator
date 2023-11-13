#!/bin/bash

# ============================================================================
# Script de Configuración Automática del Proyecto DevOps
# Calculadora de Calorías en Python
# Se ejecuta en el directorio actual y usa backdated commits
# ============================================================================

set -e  # Detener el script si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# ============================================================================
# PASO 0: Configuración Inicial
# ============================================================================

print_step "PASO 0: Configuración Inicial"

# Repositorio configurado
REPO_URL="git@github.com:rodrigoacd/calorie_calculator.git"
GITHUB_USERNAME="rodrigoacd"

# Solicitar solo el email
read -p "Ingresa tu email de GitHub: " GITHUB_EMAIL

# Usar directorio actual
PROJECT_DIR=$(pwd)

print_message "Proyecto se creará en: $PROJECT_DIR"
print_message "Repositorio: $REPO_URL"

# Calcular fecha de hace 2 años
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    TWO_YEARS_AGO=$(date -v-2y "+%Y-%m-%d %H:%M:%S")
else
    # Linux
    TWO_YEARS_AGO=$(date -d "2 years ago" "+%Y-%m-%d %H:%M:%S")
fi

print_message "Fecha base para commits: $TWO_YEARS_AGO"

# Verificar si Python3 está instalado
if ! command -v python3 &> /dev/null; then
    print_error "Python3 no está instalado. Por favor, instálalo primero."
    exit 1
fi

print_message "Python3 encontrado: $(python3 --version)"

# Verificar si Git está instalado
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado. Por favor, instálalo primero."
    exit 1
fi

print_message "Git encontrado: $(git --version)"

# ============================================================================
# FUNCIÓN PARA COMMIT CON FECHA ANTIGUA
# ============================================================================

commit_with_date() {
    local message="$1"
    local days_offset="$2"  # Días a restar de la fecha base
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        COMMIT_DATE=$(date -v-2y -v+${days_offset}d "+%Y-%m-%d %H:%M:%S")
    else
        # Linux
        COMMIT_DATE=$(date -d "2 years ago + $days_offset days" "+%Y-%m-%d %H:%M:%S")
    fi
    
    GIT_AUTHOR_DATE="$COMMIT_DATE" GIT_COMMITTER_DATE="$COMMIT_DATE" git commit -m "$message"
    print_message "Commit realizado con fecha: $COMMIT_DATE"
}

# ============================================================================
# PASO 1: Crear estructura del proyecto
# ============================================================================

print_step "PASO 1: Creando estructura del proyecto"

# ============================================================================
# PASO 2: Crear aplicación de Calculadora de Calorías
# ============================================================================

print_step "PASO 2: Creando aplicación de Calculadora de Calorías"

# Crear archivo principal: calorie_calculator.py
cat > calorie_calculator.py << 'EOF'
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
    
    print(f"\nTasa Metabólica Basal (BMR): {calculator.calculate_bmr()} calorías/día")
    
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
EOF

print_message "Archivo calorie_calculator.py creado"

# Crear archivo de utilidades: nutrition_utils.py
cat > nutrition_utils.py << 'EOF'
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
EOF

print_message "Archivo nutrition_utils.py creado"

# Crear requirements.txt
cat > requirements.txt << 'EOF'
pytest==7.4.3
pytest-cov==4.1.0
EOF

print_message "Archivo requirements.txt creado"

# ============================================================================
# PASO 3: Inicializar Git y configuración
# ============================================================================

print_step "PASO 3: Inicializando repositorio Git"

git init
git config user.name "$GITHUB_USERNAME"
git config user.email "$GITHUB_EMAIL"

print_message "Git inicializado y configurado"

# Crear .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
venv/
ENV/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Testing
.pytest_cache/
.coverage
htmlcov/

# OS
.DS_Store
Thumbs.db
EOF

print_message "Archivo .gitignore creado"

# Crear README.md inicial
cat > README.md << 'EOF'
# Calculadora de Calorías - Proyecto DevOps

Una aplicación Python para calcular calorías diarias, tasa metabólica basal (BMR) y gasto energético diario total (TDEE).

## Características

- Cálculo de BMR usando la fórmula de Harris-Benedict
- Cálculo de TDEE basado en nivel de actividad
- Recomendaciones de calorías según objetivos (perder, mantener, ganar peso)
- Cálculo de distribución de macronutrientes
- Cálculo de BMI y categorización
- Recomendaciones de ingesta de agua

## Instalación

```bash
pip install -r requirements.txt
```

## Uso

```bash
python3 calorie_calculator.py
```

## Testing

```bash
pytest test_*.py -v
```

## Build

```bash
make all
```

## Autor

Rodrigo - Proyecto de demostración para CI/CD y DevOps
EOF

print_message "README.md creado"

# Commit inicial con fecha antigua
git add .
commit_with_date "Initial commit: Calorie calculator application" 0

print_message "Commit inicial realizado"

# ============================================================================
# PASO 4: Crear y trabajar con branches (feature-x, feature-y, feature-z)
# ============================================================================

print_step "PASO 4: Creando branches y generando conflictos"

# Branch feature-calculadora-bmi
print_message "Creando branch: feature-calculadora-bmi"
git checkout -b feature-calculadora-bmi

# Modificar calorie_calculator.py para agregar método bmi
cat > calorie_calculator.py << 'EOF'
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
    
    def calculate_bmi(self):
        """
        FEATURE-X: Calcula el Índice de Masa Corporal (BMI)
        
        Returns:
            float: BMI
        """
        height_m = self.height / 100
        bmi = self.weight / (height_m ** 2)
        return round(bmi, 2)
    
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
    
    print(f"\nÍndice de Masa Corporal (BMI): {calculator.calculate_bmi()}")
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
EOF

git add calorie_calculator.py
commit_with_date "feat: Add BMI calculation method" 5
print_message "Branch feature-calculadora-bmi creada y modificada"

# Volver a main y crear feature-hidratacion
git checkout main

print_message "Creando branch: feature-hidratacion"
git checkout -b feature-hidratacion

# Modificar calorie_calculator.py de manera diferente
cat > calorie_calculator.py << 'EOF'
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
EOF

git add calorie_calculator.py
commit_with_date "feat: Add water intake calculation" 10
print_message "Branch feature-hidratacion creada y modificada"

# Volver a main y crear feature-macronutrientes
git checkout main

print_message "Creando branch: feature-macronutrientes"
git checkout -b feature-macronutrientes

# Modificar calorie_calculator.py de otra manera
cat > calorie_calculator.py << 'EOF'
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
    
    def calculate_macros(self, calories, diet_type='balanced'):
        """
        FEATURE-Z: Calcula la distribución de macronutrientes
        
        Args:
            calories (float): Calorías totales diarias
            diet_type (str): Tipo de dieta
        
        Returns:
            dict: Distribución de macronutrientes
        """
        distributions = {
            'balanced': {'protein': 0.30, 'carbs': 0.40, 'fats': 0.30},
            'high_protein': {'protein': 0.40, 'carbs': 0.30, 'fats': 0.30},
            'low_carb': {'protein': 0.35, 'carbs': 0.20, 'fats': 0.45}
        }
        dist = distributions.get(diet_type, distributions['balanced'])
        return {
            'protein': round((calories * dist['protein']) / 4, 1),
            'carbs': round((calories * dist['carbs']) / 4, 1),
            'fats': round((calories * dist['fats']) / 9, 1)
        }
    
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
    
    print(f"\nTasa Metabólica Basal (BMR): {calculator.calculate_bmr()} calorías/día")
    
    tdee = calculator.calculate_tdee('moderate')
    print(f"TDEE (actividad moderada): {tdee} calorías/día")
    
    macros = calculator.calculate_macros(tdee)
    print(f"\nDistribución de macronutrientes (dieta balanceada):")
    print(f"  Proteína: {macros['protein']}g")
    print(f"  Carbohidratos: {macros['carbs']}g")
    print(f"  Grasas: {macros['fats']}g")
    
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
EOF

git add calorie_calculator.py
commit_with_date "feat: Add macronutrient calculation" 15
print_message "Branch feature-macronutrientes creada y modificada"

# Volver a main
git checkout main

print_message "Todos los branches creados exitosamente"

# ============================================================================
# PASO 5: Conectar con GitHub y subir branches
# ============================================================================

print_step "PASO 5: Conectando con GitHub y subiendo código"

print_message "Agregando remote origin..."
git remote add origin "$REPO_URL"

print_message "Renombrando branch a main..."
git branch -M main

print_message "Subiendo main a GitHub..."
git push -u origin main --force

print_message "Subiendo todos los branches..."
git push origin feature-calculadora-bmi
git push origin feature-hidratacion
git push origin feature-macronutrientes

print_step "Código subido a GitHub exitosamente"

# ============================================================================
# PASO 6: Instrucciones para continuar
# ============================================================================

cat > INSTRUCCIONES_SIGUIENTES_PASOS.txt << 'EOF'
============================================================================
INSTRUCCIONES PARA CONTINUAR - PASOS SIGUIENTES
============================================================================

✅ COMPLETADO:
- Aplicación Python creada (calorie_calculator.py, nutrition_utils.py)
- Repositorio Git inicializado con commits antiguos (hace 2 años)
- 3 branches creados con conflictos:
  * feature-calculadora-bmi
  * feature-hidratacion
  * feature-macronutrientes
- Todo el código subido a: git@github.com:rodrigoacd/calorie_calculator.git

============================================================================
PRÓXIMOS PASOS - HACER EN GITHUB:
============================================================================

PASO 1: MERGE DE FEATURE-CALCULADORA-BMI (via Pull Request)
-----------------------------------------------------------
1. Ve a: https://github.com/rodrigoacd/calorie_calculator
2. Click en "Pull requests" → "New pull request"
3. Base: main, Compare: feature-calculadora-bmi
4. Click "Create pull request"
5. Título: "feat: Add BMI calculation method"
6. Click "Create pull request"
7. Click "Merge pull request" → "Confirm merge"
✓ Primer feature mergeado

PASO 2: MERGE DE FEATURE-HIDRATACION (via Git CLI con conflicto)
---------------------------------------------------------------
En tu terminal, ejecuta:

cd "$(pwd)"
git checkout main
git pull origin main
git merge feature-hidratacion

⚠️ HABRÁ CONFLICTO - Para resolverlo:

1. Abre calorie_calculator.py en tu editor
2. Busca las líneas con <<<<<<, ======, >>>>>>
3. MANTÉN AMBOS MÉTODOS: calculate_bmi() Y calculate_water_intake()
4. Elimina los marcadores de conflicto
5. El código debe quedar con AMBOS métodos juntos
6. Guarda el archivo

Luego:
git add calorie_calculator.py
GIT_AUTHOR_DATE="2022-11-27 10:00:00" GIT_COMMITTER_DATE="2022-11-27 10:00:00" \
  git commit -m "Merge feature-hidratacion: Resolve conflict, keep both features"
git push origin main

✓ Segundo feature mergeado desde CLI

PASO 3: MERGE DE FEATURE-MACRONUTRIENTES (via GitHub con conflicto)
------------------------------------------------------------------
1. Ve a: https://github.com/rodrigoacd/calorie_calculator
2. Click en "Pull requests" → "New pull request"
3. Base: main, Compare: feature-macronutrientes
4. Click "Create pull request"
5. Título: "feat: Add macronutrient calculation"

⚠️ GitHub te mostrará conflictos:

6. Click "Resolve conflicts"
7. En el editor web:
   - MANTÉN LOS 3 MÉTODOS: calculate_bmi(), calculate_water_intake() Y calculate_macros()
   - Elimina los marcadores <<<<<<, ======, >>>>>>
   - Asegúrate que los 3 métodos queden en la clase
8. Click "Mark as resolved" → "Commit merge"
9. Click "Merge pull request" → "Confirm merge"

✓ Tercer feature mergeado desde GitHub

PASO 4: ACTUALIZAR REPOSITORIO LOCAL
------------------------------------
cd "$(pwd)"
git checkout main
git pull origin main

============================================================================

AHORA EJECUTA LOS SIGUIENTES SCRIPTS EN ORDEN:

1. ./setup_unit_tests.sh
   (Crea branch unit-test, agrega tests, sube a GitHub)

2. Luego en GitHub: crea Pull Request para merge unit-test → main

3. ./setup_build_automation.sh
   (Agrega Makefile y build.py, sube a main)

4. ./generate_report.sh
   (Genera el reporte final del proyecto)

============================================================================
EOF

print_message "Archivo INSTRUCCIONES_SIGUIENTES_PASOS.txt creado"

# ============================================================================
# Crear scripts adicionales con commits antiguos
# ============================================================================

print_step "Creando scripts adicionales"

cat > setup_unit_tests.sh << 'EOFSCRIPT'
#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Función para commit con fecha antigua
commit_with_old_date() {
    local message="$1"
    local date="$2"
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "$message"
}

print_step "CONFIGURACIÓN DE UNIT TESTING"

# Crear branch unit-test
print_message "Creando branch: unit-test"
git checkout main
git pull origin main
git checkout -b unit-test

# Crear archivos de test
print_message "Creando archivos de pruebas unitarias..."

cat > test_calorie_calculator.py << 'EOF'
"""
Tests unitarios para CalorieCalculator
5 test cases: 3 pasan, 2 fallan intencionalmente
"""
import pytest
from calorie_calculator import CalorieCalculator


class TestCalorieCalculator:
    """Suite de pruebas para CalorieCalculator"""
    
    def setup_method(self):
        """Configuración antes de cada test"""
        self.calc_male = CalorieCalculator(age=30, weight=70, height=175, gender='male')
        self.calc_female = CalorieCalculator(age=25, weight=60, height=165, gender='female')
    
    # ===== TESTS QUE PASAN =====
    
    def test_bmr_calculation_male(self):
        """TEST 1 (PASS): Verifica cálculo de BMR para hombre"""
        bmr = self.calc_male.calculate_bmr()
        expected = 88.362 + (13.397 * 70) + (4.799 * 175) - (5.677 * 30)
        assert abs(bmr - expected) < 0.1, f"BMR esperado ~{expected}, obtenido {bmr}"
    
    def test_tdee_calculation(self):
        """TEST 2 (PASS): Verifica cálculo de TDEE"""
        tdee = self.calc_male.calculate_tdee('moderate')
        bmr = self.calc_male.calculate_bmr()
        expected = bmr * 1.55
        assert abs(tdee - expected) < 0.1, f"TDEE esperado ~{expected}, obtenido {tdee}"
    
    def test_calories_for_weight_loss(self):
        """TEST 3 (PASS): Verifica calorías para pérdida de peso"""
        result = self.calc_male.calories_for_goal('lose', 'moderate')
        assert 'bmr' in result
        assert 'tdee' in result
        assert 'recommended_calories' in result
        assert result['recommended_calories'] < result['tdee']
        assert result['recommended_calories'] == result['tdee'] - 500
    
    # ===== TESTS QUE FALLAN INTENCIONALMENTE =====
    
    def test_bmr_unrealistic_value_FAIL(self):
        """TEST 4 (FAIL): Test diseñado para fallar - valor BMR poco realista"""
        bmr = self.calc_male.calculate_bmr()
        assert bmr > 5000, f"FALLO INTENCIONAL: BMR debería ser >5000, obtenido {bmr}"
    
    def test_invalid_activity_level_FAIL(self):
        """TEST 5 (FAIL): Test diseñado para fallar - nivel de actividad inválido"""
        try:
            tdee = self.calc_male.calculate_tdee('super_extreme')
            assert True
        except ValueError:
            pytest.fail("FALLO INTENCIONAL: Se esperaba que aceptara 'super_extreme' pero lanzó ValueError")


if __name__ == "__main__":
    pytest.main([__file__, '-v'])
EOF

cat > test_nutrition_utils.py << 'EOF'
"""
Tests unitarios para funciones de nutrition_utils
"""
import pytest
from nutrition_utils import calculate_macros, bmi_category, water_intake


def test_macros_balanced_diet():
    """Verifica distribución de macros en dieta balanceada"""
    macros = calculate_macros(2000, 'balanced')
    assert macros['protein'] == 150.0
    assert macros['carbs'] == 200.0
    assert abs(macros['fats'] - 66.7) < 0.1


def test_bmi_calculation():
    """Verifica cálculo de BMI"""
    result = bmi_category(70, 175)
    expected_bmi = 70 / (1.75 ** 2)
    assert abs(result['bmi'] - expected_bmi) < 0.1
    assert result['category'] == "Peso normal"


def test_water_intake():
    """Verifica cálculo de ingesta de agua"""
    water = water_intake(70, 'moderate')
    expected = 70 * 0.033 * 1.2
    assert abs(water - expected) < 0.1


if __name__ == "__main__":
    pytest.main([__file__, '-v'])
EOF

print_message "Archivos de test creados"

# Instalar pytest
print_message "Instalando dependencias de testing..."
pip3 install pytest pytest-cov --break-system-packages 2>/dev/null || pip3 install pytest pytest-cov

# Ejecutar tests
print_message "Ejecutando tests..."
pytest test_*.py -v || true

# Commit con fecha antigua
git add test_*.py

if [[ "$OSTYPE" == "darwin"* ]]; then
    OLD_DATE=$(date -v-2y -v+30d "+%Y-%m-%d %H:%M:%S")
else
    OLD_DATE=$(date -d "2 years ago + 30 days" "+%Y-%m-%d %H:%M:%S")
fi

commit_with_old_date "test: Add unit tests (5 test cases: 3 pass, 2 fail intentionally)" "$OLD_DATE"
git push origin unit-test

print_step "Unit Testing completado"
print_message "Ve a GitHub y crea un Pull Request para merge 'unit-test' → 'main'"
print_message "Después de hacer el merge en GitHub, ejecuta: ./setup_build_automation.sh"

EOFSCRIPT

chmod +x setup_unit_tests.sh

cat > setup_build_automation.sh << 'EOFSCRIPT'
#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

commit_with_old_date() {
    local message="$1"
    local date="$2"
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "$message"
}

print_step "CONFIGURACIÓN DE BUILD AUTOMATION"

git checkout main
git pull origin main

# Crear Makefile
cat > Makefile << 'EOF'
.PHONY: help install test clean build run all

PYTHON := python3
PIP := pip3
PROJECT_NAME := calorie-calculator
DIST_DIR := dist
BUILD_DIR := build

GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help:
	@echo "$(GREEN)========================================"
	@echo " Calculadora de Calorías - Build Script"
	@echo "========================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Comandos disponibles:$(NC)"
	@echo "  make install    - Instala dependencias"
	@echo "  make test       - Ejecuta tests unitarios"
	@echo "  make build      - Crea paquete distribuible"
	@echo "  make clean      - Limpia archivos generados"
	@echo "  make run        - Ejecuta la aplicación"
	@echo "  make all        - Pipeline completo (install → test → build)"

install:
	@echo "$(GREEN)[1/3] Instalando dependencias...$(NC)"
	$(PIP) install -r requirements.txt --break-system-packages 2>/dev/null || $(PIP) install -r requirements.txt
	@echo "$(GREEN)✓ Dependencias instaladas$(NC)"

test:
	@echo "$(GREEN)[2/3] Ejecutando tests...$(NC)"
	$(PYTHON) -m pytest test_*.py -v --tb=short || true
	@echo "$(GREEN)✓ Tests completados$(NC)"

build: clean
	@echo "$(GREEN)[3/3] Creando paquete distribuible...$(NC)"
	@mkdir -p $(DIST_DIR) $(BUILD_DIR)
	@cp calorie_calculator.py nutrition_utils.py requirements.txt README.md $(DIST_DIR)/
	@echo '#!/usr/bin/env python3' > $(DIST_DIR)/run_calculator.py
	@cat calorie_calculator.py >> $(DIST_DIR)/run_calculator.py
	@chmod +x $(DIST_DIR)/run_calculator.py
	@cd $(DIST_DIR) && zip -r ../$(BUILD_DIR)/$(PROJECT_NAME).zip . > /dev/null
	@echo "$(GREEN)✓ Build completado$(NC)"

clean:
	@rm -rf $(DIST_DIR) $(BUILD_DIR) __pycache__ .pytest_cache *.pyc
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

run:
	@echo "$(GREEN)Ejecutando aplicación...$(NC)"
	$(PYTHON) calorie_calculator.py

all: install test build
	@echo "$(GREEN)✓ Pipeline completado exitosamente$(NC)"
EOF

# Crear build.py
cat > build.py << 'EOF'
#!/usr/bin/env python3
"""Script de Build Automation"""
import os, sys, shutil, subprocess, zipfile
from pathlib import Path

class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    NC = '\033[0m'

def print_step(msg):
    print(f"\n{Colors.GREEN}========================================")
    print(msg)
    print(f"========================================{Colors.NC}\n")

def clean():
    print_step("Limpiando archivos generados")
    for d in ['dist', 'build', '__pycache__', '.pytest_cache']:
        if os.path.exists(d):
            shutil.rmtree(d)
    print(f"{Colors.GREEN}✓ Limpieza completada{Colors.NC}")

def install():
    print_step("Instalando dependencias")
    try:
        subprocess.run([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt', 
                       '--break-system-packages'], capture_output=True)
        print(f"{Colors.GREEN}✓ Dependencias instaladas{Colors.NC}")
        return True
    except:
        return False

def test():
    print_step("Ejecutando tests unitarios")
    subprocess.run([sys.executable, '-m', 'pytest', 'test_*.py', '-v'], check=False)
    return True

def build():
    print_step("Creando paquete distribuible")
    clean()
    Path('dist').mkdir(exist_ok=True)
    Path('build').mkdir(exist_ok=True)
    
    for f in ['calorie_calculator.py', 'nutrition_utils.py', 'requirements.txt', 'README.md']:
        if os.path.exists(f):
            shutil.copy(f, Path('dist') / f)
    
    with open('dist/run_calculator.py', 'w') as out:
        out.write('#!/usr/bin/env python3\n')
        with open('calorie_calculator.py') as src:
            out.write(src.read())
    os.chmod('dist/run_calculator.py', 0o755)
    
    with zipfile.ZipFile('build/calorie-calculator.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file in Path('dist').rglob('*'):
            if file.is_file():
                zipf.write(file, file.relative_to('dist'))
    
    print(f"{Colors.GREEN}✓ Build completado{Colors.NC}")
    return True

def run():
    subprocess.run([sys.executable, 'calorie_calculator.py'])
    return True

def all_steps():
    install() and test() and build()
    print(f"\n{Colors.GREEN}✓ Pipeline completado{Colors.NC}\n")
    return True

if __name__ == "__main__":
    cmds = {'install': install, 'test': test, 'build': build, 'clean': clean, 
            'run': run, 'all': all_steps}
    if len(sys.argv) < 2 or sys.argv[1] not in cmds:
        print("Uso: python3 build.py [install|test|build|clean|run|all]")
        sys.exit(1)
    cmds[sys.argv[1]]()
EOF

chmod +x build.py

# Crear Readme.txt
cat > Readme.txt << 'EOF'
============================================================================
CALCULADORA DE CALORÍAS - INSTRUCCIONES DE BUILD
============================================================================

MÉTODO 1: Makefile (Recomendado para Mac/Linux)
===============================================

  make all         - Pipeline completo (install → test → build)
  make install     - Instala dependencias
  make test        - Ejecuta tests unitarios
  make build       - Crea paquete distribuible
  make clean       - Limpia archivos generados
  make run         - Ejecuta la aplicación

MÉTODO 2: build.py (Multiplataforma)
====================================

  python3 build.py all         - Pipeline completo
  python3 build.py install     - Instala dependencias
  python3 build.py test        - Ejecuta tests
  python3 build.py build       - Crea paquete
  python3 build.py clean       - Limpia archivos
  python3 build.py run         - Ejecuta aplicación

ESTRUCTURA DEL PROYECTO
=======================

calorie-calculator/
├── calorie_calculator.py      # Aplicación principal
├── nutrition_utils.py          # Utilidades
├── test_calorie_calculator.py  # Tests (5 tests: 3 pass, 2 fail)
├── test_nutrition_utils.py     # Tests de utilidades
├── requirements.txt            # Dependencias
├── Makefile                    # Build automation
├── build.py                    # Build script Python
├── Readme.txt                  # Este archivo
└── README.md                   # Documentación

DISTRIBUCIÓN
============

Después del build:
  - dist/ (código fuente)
  - build/calorie-calculator.zip (paquete completo)

============================================================================
EOF

print_message "Archivos de build creados"

# Ejecutar pipeline
print_message "Ejecutando pipeline de build..."
make all 2>/dev/null || python3 build.py all

# Commit con fecha antigua
git add Makefile build.py Readme.txt

if [[ "$OSTYPE" == "darwin"* ]]; then
    OLD_DATE=$(date -v-2y -v+45d "+%Y-%m-%d %H:%M:%S")
else
    OLD_DATE=$(date -d "2 years ago + 45 days" "+%Y-%m-%d %H:%M:%S")
fi

commit_with_old_date "build: Add build automation with Makefile and build.py" "$OLD_DATE"
git push origin main

print_step "Build Automation completado"
print_message "Ahora ejecuta: ./generate_report.sh"

EOFSCRIPT

chmod +x setup_build_automation.sh

cat > generate_report.sh << 'EOFSCRIPT'
#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

commit_with_old_date() {
    local message="$1"
    local date="$2"
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git commit -m "$message"
}

print_step "GENERANDO REPORTE DEL PROYECTO"

REPO_URL="https://github.com/rodrigoacd/calorie_calculator"

cat > REPORTE_PROYECTO.md << EOF
# Reporte del Proyecto DevOps - Calculadora de Calorías

## Información del Repositorio

**URL del Repositorio:** $REPO_URL

**Lenguaje:** Python 3  
**Framework de Testing:** pytest  
**Build Automation:** Make / Python Script

---

## 1. Source Control (Git y GitHub)

### Estructura de Branches

- **main**: Branch principal
- **feature-calculadora-bmi**: Cálculo de BMI
- **feature-hidratacion**: Cálculo de ingesta de agua
- **feature-macronutrientes**: Distribución de macronutrientes
- **unit-test**: Pruebas unitarias

### Manejo de Conflictos

1. **Merge via Pull Request (GitHub)**: feature-calculadora-bmi → main
2. **Merge via Git CLI**: feature-hidratacion → main (con resolución de conflicto)
3. **Merge via Pull Request con conflicto**: feature-macronutrientes → main

---

## 2. Unit Testing

### Framework: pytest

Se crearon 5 casos de prueba:

**Tests que PASAN (3):**
1. test_bmr_calculation_male
2. test_tdee_calculation
3. test_calories_for_weight_loss

**Tests que FALLAN (2):**
4. test_bmr_unrealistic_value_FAIL
5. test_invalid_activity_level_FAIL

---

## 3. Build Automation

### Herramientas: Makefile + build.py

**Pipeline:**
\`\`\`bash
make all  # o: python3 build.py all
\`\`\`

1. Instalación de dependencias
2. Ejecución de tests
3. Creación de paquete distribuible

**Resultado:**
- dist/ (código fuente)
- build/calorie-calculator.zip (paquete)

---

## 4. Infrastructure as Code (IaC)

### Concepto

IaC es gestionar infraestructura mediante código versionado, permitiendo:
- Automatización completa
- Reproducibilidad
- Versionamiento
- Testing de infraestructura

### Beneficios en DevOps

1. **Consistencia**: Entornos idénticos
2. **Velocidad**: Provisión en minutos
3. **Documentación**: El código es la documentación
4. **Escalabilidad**: Fácil replicación
5. **Recuperación**: Recreación rápida
6. **Testing**: Validación automatizada
7. **Colaboración**: Pull requests de infraestructura
8. **Costos**: Optimización de recursos

### Herramientas Comunes

**Aprovisionamiento:**
- Terraform
- CloudFormation
- Pulumi

**Configuración:**
- Ansible
- Puppet
- Chef

**Contenedores:**
- Docker
- Kubernetes
- Docker Compose

---

## 5. Conclusiones

### Logros

✓ Source control con Git/GitHub  
✓ 5 tests unitarios implementados  
✓ Build automation completo  
✓ Documentación profesional  

### Próximos Pasos

1. CI/CD con GitHub Actions
2. Dockerización
3. Despliegue automatizado
4. Monitoreo y logging

---

**Fecha:** $(date +"%d/%m/%Y")  
**Repositorio:** $REPO_URL

EOF

print_message "Reporte generado: REPORTE_PROYECTO.md"

git add REPORTE_PROYECTO.md

if [[ "$OSTYPE" == "darwin"* ]]; then
    OLD_DATE=$(date -v-2y -v+50d "+%Y-%m-%d %H:%M:%S")
else
    OLD_DATE=$(date -d "2 years ago + 50 days" "+%Y-%m-%d %H:%M:%S")
fi

commit_with_old_date "docs: Add comprehensive project report" "$OLD_DATE"
git push origin main

print_step "¡PROYECTO COMPLETADO!"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}║  ✓ PROYECTO DEVOPS COMPLETADO EXITOSAMENTE    ║${NC}"
echo -e "${GREEN}║                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Repositorio:${NC} $REPO_URL"
echo ""
echo -e "${GREEN}Todos los commits tienen fechas de hace 2 años${NC}"
echo ""

EOFSCRIPT

chmod +x generate_report.sh

print_message "Scripts adicionales creados"

# ============================================================================
# Mensaje final
# ============================================================================

print_step "¡CONFIGURACIÓN INICIAL COMPLETADA!"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}║     PROYECTO DEVOPS - CALCULADORA DE CALORÍAS         ║${NC}"
echo -e "${GREEN}║     ✓ Commits con fechas de hace 2 años              ║${NC}"
echo -e "${GREEN}║                                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Directorio del proyecto:${NC} $PROJECT_DIR"
echo -e "${BLUE}Repositorio GitHub:${NC} $REPO_URL"
echo ""
echo -e "${GREEN}✓ Archivos creados:${NC}"
echo "  - calorie_calculator.py"
echo "  - nutrition_utils.py"
echo "  - requirements.txt"
echo "  - README.md"
echo "  - .gitignore"
echo ""
echo -e "${GREEN}✓ Git configurado:${NC}"
echo "  - Repositorio inicializado"
echo "  - Remote agregado: $REPO_URL"
echo "  - 3 branches creados con conflictos"
echo "  - Todo subido a GitHub"
echo ""
echo -e "${GREEN}✓ Scripts creados:${NC}"
echo "  - setup_unit_tests.sh"
echo "  - setup_build_automation.sh"
echo "  - generate_report.sh"
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}IMPORTANTE: COMMITS CON FECHAS ANTIGUAS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Todos los commits tienen fechas de hace aproximadamente 2 años${NC}"
echo -e "Esto simula un proyecto con historial antiguo."
echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}PRÓXIMOS PASOS:${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Lee:${NC} ${BLUE}INSTRUCCIONES_SIGUIENTES_PASOS.txt${NC}"
echo ""
echo -e "Luego ejecuta en orden:"
echo -e "  ${BLUE}1. ./setup_unit_tests.sh${NC}"
echo -e "  ${BLUE}2. ./setup_build_automation.sh${NC}"
echo -e "  ${BLUE}3. ./generate_report.sh${NC}"
echo ""
echo -e "${GREEN}¡Proyecto configurado exitosamente!${NC}"
echo ""