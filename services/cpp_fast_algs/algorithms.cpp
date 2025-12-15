#include <cstdlib>
#include <algorithm>

// Define NULL para compatibilidad con FFI
#ifndef NULL
#define NULL 0
#endif

// Función expuesta a Ruby (FFI)
// Implementa un algoritmo de ordenamiento simple (ej. bubble sort o std::sort)
// para demostrar el rendimiento C++ vs. Ruby.
extern "C" int *fast_sort(int *data, int size) {

    // Devolver NULL (puntero nulo) si el tamaño es <= 0.
    if (size <= 0) {
        return NULL; // Devuelve NULL para indicar un error o resultado vacío.
    }

    // 1. Asignar memoria para el array de resultados.
    // Usamos 'new' en C++ o 'malloc' en C para asignación de memoria dinámica.
    // El resultado debe ser liberado por el llamador (Ruby FFI).
    int *result = (int *)malloc(sizeof(int) * size);

    // 2. Copiar los datos de entrada al array de resultados.
    // Es buena práctica no modificar los datos de entrada ('data').
    for (int i = 0; i < size; ++i) {
        result[i] = data[i];
    }

    // 3. Aplicar el algoritmo de ordenamiento de la librería estándar (más eficiente que un bubble sort manual).
    std::sort(result, result + size);

    // Devolver el puntero al array ordenado.
    return result;
}

