# lib/math_calculator.rb
require 'json'
module CompSciToolbox
  module Math
    class Calculator
      PYTHON_SCRIPT = File.expand_path('../../services/python_ai_calc/main.py', __FILE__)
      PYTHON_EXECUTABLE = File.expand_path('../../.venv/python/Scripts/python.exe', __FILE__)

      def self.calculate_eigenvalues(matrix_data)
        data_string = matrix_data.flatten.join(',')

        # === Definir el comando como una cadena para consistencia ===
        command = "#{PYTHON_EXECUTABLE} #{PYTHON_SCRIPT} \"#{data_string}\"" 
        # ===================================================================================

        output = ""
        # Ejecutamos con IO.popen y el flag 'r:binary' para evitar el problema de codificación.
        IO.popen(command, "r:binary") do |io| # Pasamos la cadena de comando simple.
          raw_output = io.read 
          
          if raw_output
            # Aplicamos el manejo de codificación de forma segura
            output = raw_output.force_encoding('UTF-8')
                               .encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
                               .strip
          end
        end

        if output.start_with?("SUCCESS:")
          result_str = output.sub("SUCCESS:", "")
          # Esto interpreta la cadena JSON de forma segura.
          return JSON.parse(result_str)
        else
          # Usamos la variable 'command' que es conocida en todo el método
          raise "Error en el servicio Python.\nComando ejecutado: #{command}\nSalida del shell (stdout/stderr): #{output}"
        end
      end
    end
  end
end