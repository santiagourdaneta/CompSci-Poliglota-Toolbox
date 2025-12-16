# frozen_string_literal: true
# lib/math_calculator.rb
require 'json'
require 'open3' # Importamos Open3 para una ejecución de comandos robusta (captura stderr)

module CompSciToolbox
  module Math
    # Clase que maneja la comunicación con el script de Python para el cálculo numérico (Eigenvalores).
    class Calculator
      
      # Lógica condicional para definir el ejecutable y la ruta del script según la plataforma
      if RUBY_PLATFORM =~ /mingw|mswin/
        # --- ENTORNO WINDOWS ---
        # Usa el ejecutable dentro del entorno virtual local (.venv)
        PYTHON_EXECUTABLE = File.expand_path('../../.venv/python/Scripts/python.exe', __FILE__)
        # Ruta del script
        PYTHON_SCRIPT = File.expand_path('../services/python_ai_calc/main.py', __dir__)
      else
        # --- ENTORNO LINUX (Render) ---
        # Usa el comando genérico 'python3', que está en el PATH del servidor
        PYTHON_EXECUTABLE = 'python3'
        # La ruta del script debe ser relativa a la raíz del proyecto para el servidor
        PYTHON_SCRIPT = File.expand_path('../../services/python_ai_calc/main.py', __FILE__)
      end

      # rubocop:disable Metrics/MethodLength
      # El método está simplificado al delegar la validación y el parsing.
      def self.calculate_eigenvalues(matrix_data)
        raise ArgumentError, 'La entrada debe ser una matriz (Array de Arrays).' unless matrix_data.is_a?(Array)

        # Aplanar y unir con comas para la entrada de Python
        data_string = matrix_data.flatten.join(',')
        
        # Array de comandos (seguro contra Command Injection)
        command_array = [
          PYTHON_EXECUTABLE,
          PYTHON_SCRIPT,
          data_string # Los datos se pasan como un argumento
        ]

        # Ejecución del proceso externo usando Open3 para capturar stdout, stderr y el estado
        begin
          # Open3.capture3 devuelve [stdout, stderr, status]
          stdout, stderr, status = Open3.capture3(*command_array)
          
          unless status.success?
             # Si la ejecución falló a nivel de sistema (ej: script no encontrado o error de Python)
             command_display = command_array.join(' ')
             # ¡Importante! Imprimir el error de Python en el log de Render
             puts "❌ ERROR IPC PYTHON. Stderr: #{stderr.strip}. Comando: #{command_display}"
             raise "Error de Ejecución de Script Python. Stderr: #{stderr.strip}. Comando: #{command_display}"
          end
          
          # La validación y el parsing JSON
          validate_and_parse_output(stdout.strip, command_array)
          
        rescue Errno::ENOENT => e
           # Esto captura si 'python3' o el script NO se encuentra o no tiene permisos
           command_display = command_array.join(' ')
           puts "❌ ERROR: Comando IPC no encontrado. ¿Faltan permisos o la ruta es incorrecta? Comando: #{command_display}. Error: #{e.message}"
           raise "Error de Comando IPC: #{e.message}"
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      # Separa la lógica de validación de salida y manejo de errores.
      def self.validate_and_parse_output(output, command_info)
        # 1. Verificar si el script de Python terminó con el prefijo de éxito.
        unless output.start_with?('SUCCESS:')
          # Convertir el Array de comandos en un string legible para el mensaje de error.
          command_display = command_info.join(' ')
          
          # La variable 'command' existe dentro del scope de esta función como 'command_display'.
          raise "Error en el servicio Python.\nComando ejecutado: #{command_display}\nSalida inesperada (stdout): #{output}"
        end

        # 2. Quitar el prefijo de éxito y parsear JSON.
        result_str = output.sub('SUCCESS:', '').strip
        
        # Intenta interpretar la cadena JSON de forma segura.
        JSON.parse(result_str)
      rescue JSON::ParserError => e
        raise "Error de parsing JSON en la salida de Python. Salida: #{result_str[0..50]}...\nError: #{e.message}"
      end
    end
  end
end