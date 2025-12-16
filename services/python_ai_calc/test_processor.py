import json
import numpy as np
import pytest
import math

from main import calculate_eigenvalues

# Función auxiliar para parsear la salida JSON etiquetada
def parse_success_output(captured_stdout):
    """Extrae y decodifica el JSON de la salida etiquetada SUCCESS:"""
    output = captured_stdout.out.strip()
    if output.startswith("SUCCESS:"):
        json_str = output.replace("SUCCESS:", "")
        return json.loads(json_str)
    return None

# --- Pruebas de Funcionalidad Matemática (Cálculo) ---

def test_eigenvalues_real_distinct_roots(capsys):
    """Prueba una matriz con Eigenvalores reales distintos (ej: 5 y 0)."""
    # Matriz A = [[4, -2], [1, 1]]. Eigenvalores: 3 ± sqrt(2)
    # Tr(A) = 5, Det(A) = 6. Lambda^2 - 5*Lambda + 6 = 0 -> (Lambda-3)(Lambda-2) = 0
    test_matrix = "4.0,-2.0,1.0,1.0"
    
    # La matriz que se muestra en el comentario tiene Eigenvalores 3 y 2.
    # Corregiremos la matriz para que coincida con 3 y 2: [[4, -2], [1, 1]]
    test_matrix = "4.0,-2.0,1.0,1.0" 

    calculate_eigenvalues(test_matrix)
    captured = capsys.readouterr()
    result_list = parse_success_output(captured)
    
    # Los resultados de NumPy pueden estar en cualquier orden.
    assert result_list is not None
    
    # La solución de Lambda^2 - 5*Lambda + 6 = 0 es 3 y 2.
    expected_eigenvalues = [3.0, 2.0]
    
    # Comparamos si los valores calculados son aproximadamente iguales a los esperados
    # Note: math.isclose maneja comparaciones de flotantes de forma segura
    assert math.isclose(result_list[0], expected_eigenvalues[0], abs_tol=1e-9) or \
           math.isclose(result_list[0], expected_eigenvalues[1], abs_tol=1e-9)
    assert math.isclose(result_list[1], expected_eigenvalues[0], abs_tol=1e-9) or \
           math.isclose(result_list[1], expected_eigenvalues[1], abs_tol=1e-9)

def test_eigenvalues_complex_roots(capsys):
    """Prueba una matriz con Eigenvalores complejos (ej: 0.5 + 0.866i)."""
    # Matriz de rotación/escalado: [[0, -1], [1, 0]]. Eigenvalores: i, -i
    test_matrix = "0.0,-1.0,1.0,0.0"
    
    calculate_eigenvalues(test_matrix)
    captured = capsys.readouterr()
    result_list = parse_success_output(captured)
    
    assert result_list is not None
    
    # NumPy devuelve objetos complejos, JSON los serializa como listas: [real, imaginario]
    # Esperamos [0.0, 1.0] (para +i) y [0.0, -1.0] (para -i)
    expected_roots = [[0.0, 1.0], [0.0, -1.0]]
    
    # Comparamos si los resultados son aproximadamente iguales a las raíces esperadas
    root1_matches_expected = (math.isclose(result_list[0][0], expected_roots[0][0]) and math.isclose(result_list[0][1], expected_roots[0][1])) or \
                             (math.isclose(result_list[0][0], expected_roots[1][0]) and math.isclose(result_list[0][1], expected_roots[1][1]))
    
    assert root1_matches_expected

# --- Pruebas de Manejo de Errores y Validación ---

def test_input_error_invalid_format(capsys):
    """Prueba que el script maneje errores de formato de entrada (no es un número)."""
    invalid_input = "4.0,a,1.0,1.0"
    
    with pytest.raises(SystemExit) as excinfo:
        calculate_eigenvalues(invalid_input)
    
    # Verifica que el código de salida sea 1
    assert excinfo.value.code == 1
    
    # Verifica que el error fatal se haya escrito en stderr
    captured = capsys.readouterr()
    assert "FATAL ERROR en el servicio Python" in captured.err

def test_input_error_wrong_dimension(capsys):
    """Prueba que el script rechace entradas que no son 2x2 (ej: 3 elementos)."""
    wrong_input = "4.0,1.0,1.0" # 3 elementos
    
    with pytest.raises(SystemExit) as excinfo:
        calculate_eigenvalues(wrong_input)
    
    assert excinfo.value.code == 1
    
    captured = capsys.readouterr()
    assert "Se esperaban 4 elementos para una matriz 2x2" in captured.err

# --- Prueba de Logging (Stderr) ---

def test_logging_messages(capsys):
    """Verifica que el script escriba los mensajes de estado en stderr."""
    test_matrix = "4.0,-2.0,1.0,1.0"
    
    calculate_eigenvalues(test_matrix)
    captured = capsys.readouterr()
    
    assert "Python Service: Iniciando cálculo de Eigenvalores..." in captured.err
    assert "Python Service: Cálculo exitoso y resultado enviado." in captured.err