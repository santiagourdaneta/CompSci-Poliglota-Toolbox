#ifndef SORTING_H
#define SORTING_H

// Función que será llamada desde Ruby
extern "C" {
    void fast_sort_c(int* arr, int size);
}

#endif // SORTING_H