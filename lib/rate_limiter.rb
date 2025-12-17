# lib/rate_limiter.rb

require 'thread'

module CompSciToolbox

  # 1. Clase de excepción pública: Usada para señalar a Sinatra que devuelva 503
  class RateLimitExceeded < StandardError; end 
  
  class RateLimiter
    # Límite de ejecución concurrente. Mantenemos la constante pero no la usamos.
    MAX_CONCURRENT = 100 
    
    @@current_count = 0
    @@mutex = Mutex.new

    def self.execute
      @@mutex.synchronize do
        if @@current_count >= MAX_CONCURRENT
          # Lanza la excepción que Sinatra interceptará
          raise RateLimitExceeded, "El límite concurrente ha sido alcanzado." 
        end
        @@current_count += 1
      end

      # Ejecución del bloque envuelto
      result = yield 

      # Liberar el recurso
      @@mutex.synchronize do
        @@current_count -= 1
      end
      
      result
    rescue
      # Si ocurre algún error DENTRO del bloque, debemos liberar el contador
      @@mutex.synchronize do
        @@current_count -= 1
      end
      # Volver a lanzar la excepción para que sea manejada por Sinatra
      raise
    end
  end
end