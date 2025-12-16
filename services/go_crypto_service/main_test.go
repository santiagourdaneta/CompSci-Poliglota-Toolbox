package main

import (
	"testing"
	"fmt"
)

// Definimos un conjunto de casos de prueba
func TestCalculateSHA256(t *testing.T) {
	// Tabla de casos de prueba: input -> expected_hash
	var tests = []struct {
		input    string
		expected string // Hash SHA-256 esperado
	}{
		// Caso 1: Cadena vacía (Standard: hash conocido)
		{"", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},
		// Caso 2: Entrada simple
		{"hello world", "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"},
		// Caso 3: Entrada con mayúsculas y caracteres especiales
		{"TestString!@#123", "105e5999254fcdbbceb219de2b2396444a3be3baea08033d4b3a121cbf2df424"},
		// Caso 4: Cadena larga (para asegurar la función Write)
		{"The quick brown fox jumps over the lazy dog.", "ef537f25c895bfa782526529a9b63d97aa631564d5d789c2b765448c8635fb6c"},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("Hash: %s", tt.input)
		t.Run(testname, func(t *testing.T) {
			// Llamar a la función 
			actual := CalculateSHA256(tt.input)

			// Verificar el resultado
			if actual != tt.expected {
				t.Errorf("Entrada: %s. Esperado: %s, Obtenido: %s", tt.input, tt.expected, actual)
			}
		})
	}
}