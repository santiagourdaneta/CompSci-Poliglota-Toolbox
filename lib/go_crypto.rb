# frozen_string_literal: true

# lib/go_crypto.rb

require 'open3'
require 'shellwords'

module CompSciToolbox

  module Security
    # Módulo que encapsula las operaciones criptográficas del proyecto,
    # utilizando el servicio externo de Go.
    class Crypto
      # Ruta al binario de Go compilado
      GO_SERVICE_PATH = File.expand_path('../services/go_crypto_service/go_crypto_service', __dir__)

      def self.generate_sha256_hash(data_string)

        # Separamos el comando y sus argumentos en un Array.
        # Ruby se encarga del 'escaping' de forma segura sin invocar un shell.
        command_array = [
          GO_SERVICE_PATH, 
          data_string # El dato a hashear (el shell de Go lo maneja)
        ]

        # Pasamos el Array directamente a Open3.capture3
        output, error, status = Open3.capture3(*command_array)

        unless status.success?
          # Si el binario de Go devuelve un código de error, lanzamos una excepción
          raise "Error al ejecutar el servicio Go (Código #{status.exitstatus}).\nComando: #{command}\nSalida de Error: #{error}"
        end

        # Verificamos si la salida es exitosa y contiene el prefijo esperado
        return output.strip.sub('SUCCESS:', '') if output.start_with?('SUCCESS:')

        # Devolvemos la salida limpia para mostrarla en la web


        # Si Go terminó bien, pero la salida no tiene el formato esperado
        raise "Formato de salida inesperado del servicio Go.\nComando: #{command}\nSalida: #{output}"
      end
    end
  end
end
