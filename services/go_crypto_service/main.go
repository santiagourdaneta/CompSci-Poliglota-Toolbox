package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"os"
)

func main() {
	// Go espera la cadena a hashear como el primer argumento de la línea de comandos
	if len(os.Args) < 2 {
		// Imprimir un mensaje de error si no se proporciona el argumento
		fmt.Printf("ERROR: Argumento faltante. Uso: go run main.go <string_a_hashear>\n")
		os.Exit(1)
	}

	inputString := os.Args[1]

	// 1. Crear el objeto hash SHA-256
	hasher := sha256.New()

	// 2. Escribir los bytes de la cadena
	hasher.Write([]byte(inputString))

	// 3. Obtener el hash resultante como un slice de bytes
	hashBytes := hasher.Sum(nil)

	// 4. Convertir los bytes del hash a una representación hexadecimal (string)
	hashHex := hex.EncodeToString(hashBytes)

	// Imprimir el resultado con el prefijo SUCCESS: para que Ruby lo reconozca
	// Se asegura que no haya saltos de línea y que el formato sea estricto.
	fmt.Printf("SUCCESS:")
}
