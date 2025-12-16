# lib/rate_limiter.rb

require 'thread'

# 1. Clase de excepción pública: Usada para señalar a Sinatra que devuelva 503
class RateLimitExceeded < StandardError; end 

module CompSciToolbox
  class RateLimiter
    # Límite de ejecución concurrente. Ajusta este valor según la capacidad de tu CPU.
    # Un valor bajo (ej. 10) asegura que el servidor rechaza peticiones bajo estrés.
    MAX_CONCURRENT = 10 
    
    @@current_count = 0
    @@mutex = Mutex.new # Objeto Mutex para proteger la variable compartida @@current_count

    def self.execute
      can_execute = false
      result = nil

      # Bloquea el acceso al contador para evitar condiciones de carrera en entornos multi-hilo (Puma)
      @@mutex.synchronize do
        if @@current_count < MAX_CONCURRENT
          @@current_count += 1
          can_execute = true
        end
      end

      if can_execute
        begin
          # Ejecuta el bloque de código de la aplicación (llamadas FFI/IPC)
          result = yield 
        ensure
          # Garantiza que el contador siempre se decrementa, incluso si el bloque falla
          @@mutex.synchronize do
            @@current_count -= 1
          end
        end
      else
        # 2. Lanza la excepción personalizada cuando el límite es cruzado
        raise RateLimitExceeded.new("Límite de concurrencia excedido. Máx: #{MAX_CONCURRENT}") 
      end
      result
    end
  end
end