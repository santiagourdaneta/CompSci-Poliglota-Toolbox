import sys
import json
import numpy as np

# Este script calcula los Eigenvalores de una matriz 2x2.
# Recibe la matriz aplanada como un argumento de cadena separada por comas.
# Ejemplo de entrada: "4.0,-2.0,1.0,1.0"

def calculate_eigenvalues(data_string):
    """
    Procesa la cadena de entrada, calcula los Eigenvalores usando NumPy y devuelve el resultado.
    """
    try:
        # 1. Procesar la entrada
        
        # Convertir la cadena de números a una lista de flotantes
        data_list = [float(x) for x in data_string.split(',')]
        
        # Verificar que la matriz sea 2x2 (4 elementos)
        if len(data_list) != 4:
            raise ValueError(f"Se esperaban 4 elementos para una matriz 2x2, pero se recibieron {len(data_list)}.")
            
        # Reformar la lista en una matriz NumPy de 2x2
        matrix = np.array(data_list).reshape(2, 2)

        # 2. Cálculo (Función principal de la librería)
        
        # Enviar mensajes de estado a la salida de error estándar (stderr)
        # Esto previene el error "RuntimeError at /" en Ruby.
        sys.stderr.write("Python Service: Iniciando cálculo de Eigenvalores...\n") 
        
        # Calcular los Eigenvalores (NumPy)
        eigenvalues = np.linalg.eigvals(matrix)

        # 3. Formatear y devolver el resultado
        
        # La salida debe ser serializable y limpia. 
        # Convertimos a una lista simple de complejos o flotantes para que Ruby pueda hacer 'eval'
        eigenvalues_list = eigenvalues.tolist()
        
        # Imprimir SOLO el resultado final etiquetado a stdout
        # La etiqueta "SUCCESS:" es vital para la validación del wrapper de Ruby (math_calculator.rb)
        print(f"SUCCESS:{eigenvalues_list}") 
        
        sys.stderr.write("Python Service: Cálculo exitoso y resultado enviado.\n") 

    except Exception as e:
        # Si hay un error, lo imprimimos en stderr y salimos con un código de error
        # El comando de Ruby capturará la salida vacía/error
        sys.stderr.write(f"FATAL ERROR en el servicio Python: {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.stderr.write("Uso: python main.py <matriz_aplanada_por_comas>\n")
        sys.exit(1)
        
    input_data = sys.argv[1]
    calculate_eigenvalues(input_data)