# lib/compsci_core.rb

require 'ffi'

module CompSciToolbox
  # Módulo para servicios de Core CompSci (C++ FFI)
  module Core
    # FFI: Foreign Function Interface
    extend FFI::Library
    
    # 1. Determinar el nombre y la ruta del binario basado en la plataforma
    lib_path = File.expand_path(File.join(__dir__, '..', 'lib'))
    
    lib_name = case RUBY_PLATFORM
               # Linux (Render)
               when /linux/ then File.join(lib_path, 'libcompsci.so')
               # Windows (Local)
               when /mingw|mswin/ then File.join(lib_path, 'libcompsci.dll')
               else
                 nil
               end

    # 2. Lógica Condicional de Carga de FFI y Fallback
    if lib_name && File.exist?(lib_name)
      begin
        ffi_lib lib_name
        puts "✅ FFI: Binario C++ cargado exitosamente desde: #{lib_name}"

        # --- DEFINICIÓN DE FUNCIONES FFI (Attach Functions) ---
        # El método C++ que expone la función de ordenamiento
        attach_function :fast_sort_c, [:pointer, :int], :void
        
        # Wrapper de Ruby para manejar la conversión de tipos
        def self.fast_sort(arr)
          return [] if arr.nil? || arr.empty?
          
          # Convertir el array de Ruby a un puntero FFI para C++
          ptr = FFI::MemoryPointer.new(:int, arr.size)
          ptr.write_array_of_int(arr)
          
          # Llamar a la función C++
          fast_sort_c(ptr, arr.size)
          
          # Leer el resultado de vuelta al array de Ruby
          ptr.read_array_of_int(arr.size)
        end
        # ------------------------------------------------------

      rescue FFI::NotFoundError => e
        puts "❌ ERROR FFI: No se pudo cargar la librería '#{lib_name}'. Error: #{e.message}"
        
        # --- FALLBACK DE RUBY ---
        def self.fast_sort(arr)
          puts "⚠️ FALLBACK: Usando método Ruby para sortear. FFI C++ no está disponible."
          arr.sort
        end
        # ------------------------
      end

    else
      # Si el archivo del binario no existe (p. ej., no ha sido compilado en la plataforma)
      puts "⚠️ ADVERTENCIA FFI: Binario C++ no encontrado en la ruta esperada: #{lib_name}. Se usará FALLBACK de Ruby."
      
      # --- FALLBACK DE RUBY ---
      def self.fast_sort(arr)
        puts "⚠️ FALLBACK: Usando método Ruby para sortear. Binario C++ no encontrado."
        arr.sort
      end
      # ------------------------
    end
    
  end
end