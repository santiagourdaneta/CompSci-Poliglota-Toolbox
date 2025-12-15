# frozen_string_literal: true

# lib/compsci_core.rb
#
# Wrapper de Ruby para el servicio de Alto Rendimiento escrito en C++.
# Utiliza FFI (Foreign Function Interface) para cargar la librería dinámica.

require 'ffi'

module CompSciToolbox
  # Módulo principal que define la conexión con el código C++
  module Core
    extend FFI::Library

    # ------------------------------------------------------------------
    # 1. Configuración de la Ruta de la Librería
    # ------------------------------------------------------------------

    # Definir la ruta relativa a la librería compilada de C++.
    lib_dir = File.expand_path('../services/cpp_fast_algs', __dir__)

    # Array de posibles nombres de archivo para ser multiplataforma
    LIB_NAMES = [
      "#{lib_dir}/libcompsci_core.so",    # Linux/Unix
      "#{lib_dir}/libcompsci_core.dll",   # Windows
      "#{lib_dir}/libcompsci_core.bundle" # macOS (a veces)
    ].freeze

    # Intentar cargar la librería
    begin
      ffi_lib LIB_NAMES
    rescue FFI::NotFoundError => e
      raise "FATAL ERROR: No se encontró la librería C++ de alto rendimiento.\n" \
            "Asegúrese de haber compilado el código C++ en: #{LIB_NAMES.join(' o ')}.\n" \
            "Detalles del Error: #{e.message}"
    end


    # ------------------------------------------------------------------
    # 2. Mapeo de la Función C++ (El Contrato)
    # ------------------------------------------------------------------

    # Mapear la función C++:
    # C Function: int* fast_sort_c(int* data, int size);
    #
    # Argumentos (Args): [ :pointer (int*), :int (size) ]
    # Retorno (Returns): :pointer (int*)

    attach_function :fast_sort_c, %i[pointer int], :pointer


    # ------------------------------------------------------------------
    # 3. Wrapper de Ruby (Método Público y Gestión de Memoria)
    # ------------------------------------------------------------------

    # rubocop:disable Metrics/MethodLength
    def self.fast_sort(data_array)
      # Validación de la entrada
      unless data_array.is_a?(Array) && data_array.all? { |i| i.is_a? Integer }
        raise ArgumentError, 'El método fast_sort solo acepta un Array de enteros.'
      end

      size = data_array.size

      # 1. Asignar memoria y escribir los datos de entrada (managed by Ruby)
      input_pointer = FFI::MemoryPointer.new(:int, size)
      input_pointer.write_array_of_int(data_array)

      # 2. Llamar a la función C++
      # C++ retorna un puntero de memoria recién asignada.
      output_pointer = fast_sort_c(input_pointer, size)

      # 3. Leer la memoria de C++ de vuelta a Ruby
      sorted_array = output_pointer.read_array_of_int(size)

      # 4. Liberar Memoria (Crucial para evitar fugas)
      # La responsabilidad de liberar el puntero retornado por malloc en C++ recae en el wrapper de Ruby.
      begin
        output_pointer.free
        input_pointer.free
      rescue StandardError => e
        # Se incluye un rescate por si la librería C++ retorna un puntero no válido,
        # aunque un error de 'free' indica un fallo en el contrato de memoria.
        puts "ADVERTENCIA FFI: Error al liberar memoria. Posiblemente doble free o puntero inválido: #{e.message}"
      end

      sorted_array
    end
    # rubocop:enable Metrics/MethodLength
  end
end
