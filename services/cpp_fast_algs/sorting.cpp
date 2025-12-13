#include "sorting.h"
#include <algorithm> // Usamos la librería estándar para la eficiencia

// Implementación del ordenamiento
extern "C" {
    void fast_sort_c(int* arr, int size) {
        // En C++, std::sort es extremadamente rápido
        std::sort(arr, arr + size);
    }
}