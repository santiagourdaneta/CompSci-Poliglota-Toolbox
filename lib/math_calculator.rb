# frozen_string_literal: true
# lib/math_calculator.rb
require 'json'

module CompSciToolbox
  module Math
    # Clase que maneja la comunicación con el script de Python para el cálculo numérico (Eigenvalores).
    class Calculator
      PYTHON_SCRIPT = File.expand_path('../services/python_ai_calc/main.py', __dir__)
      PYTHON_EXECUTABLE = File.expand_path('../../.venv/python/Scripts/python.exe', __FILE__)

      # rubocop:disable Metrics/MethodLength
      # El método esta simplificado al delegar la validación y el parsing.
      def self.calculate_eigenvalues(matrix_data)
        raise ArgumentError, 'La entrada debe ser una matriz (Array de Arrays).' unless matrix_data.is_a?(Array)

        # Aplanar y unir con comas
        # matrix_data.flatten => [1, 2, 3, 4]
        # .join(',') => "1,2,3,4"
        data_string = matrix_data.flatten.join(',')
        
        # Array de argumentos para IO.popen (Seguro contra Command Injection)
        command_array = [
          PYTHON_EXECUTABLE,
          PYTHON_SCRIPT,
          data_string # Los datos JSON se pasan como un argumento
        ]

        output = ''

        # Ejecución del proceso externo
        # IO.popen toma el Array de comandos de forma segura
        IO.popen(command_array, 'r:binary') do |io|
          output = io.read.strip
        end

        # La validación y el parsing JSON se delegan a un método privado, 
        # pasándole la salida y el array de comandos para logging de errores.
        validate_and_parse_output(output, command_array)
      end
      # rubocop:enable Metrics/MethodLength

      private

      # Separa la lógica de validación de salida y manejo de errores.
      # Recibe el Array de comandos para poder mostrarlo en el mensaje de error si falla.
      def self.validate_and_parse_output(output, command_info)
        # 1. Verificar si el script de Python terminó con el prefijo de éxito.
        unless output.start_with?('SUCCESS:')
          # Convertir el Array de comandos en un string legible para el mensaje de error.
          command_display = command_info.join(' ')
          
          # La variable 'command' existe dentro del scope de esta función como 'command_display'.
          raise "Error en el servicio Python.\nComando ejecutado: #{command_display}\nSalida del shell (stdout/stderr): #{output}"
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