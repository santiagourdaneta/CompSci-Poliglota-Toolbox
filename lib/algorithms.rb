# frozen_string_literal: true

require 'ffi'
module CompSciToolbox
  # Módulo que encapsula las operaciones de sorting del proyecto,
  # utilizando el servicio externo de Python.
  module Algorithms
    extend FFI::Library

    # Definir la ruta raíz
    PROJECT_ROOT = File.expand_path('..', __dir__)

    # Usar la ruta absoluta al archivo .dll
    LIB_PATH = File.join(PROJECT_ROOT, 'services', 'cpp_fast_algs', 'sorting.dll')

    # Carga la librería compilada como DLL
    ffi_lib LIB_PATH

    # Mapea la función de C++ a un método de Ruby
    attach_function :fast_sort_c, %i[pointer int], :void

    def self.fast_sort(data)
      # Convierte el Array de Ruby a un buffer de C para máxima velocidad
      size = data.size
      # Crea un buffer de enteros (Integer, 4 bytes)
      c_array = FFI::MemoryPointer.new(:int, size)
      c_array.write_array_of_int(data)

      # Llama a la función compilada de C++
      fast_sort_c(c_array, size)

      # Lee el resultado de vuelta a un Array de Ruby
      c_array.read_array_of_int(size)
    end
  end
end
