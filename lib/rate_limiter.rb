# lib/rate_limiter.rb

require 'thread'

# 1. Clase de excepción pública: Usada para señalar a Sinatra que devuelva 503
class RateLimitExceeded < StandardError; end 

module CompSciToolbox
  class RateLimiter
    # Límite de ejecución concurrente. Mantenemos la constante pero no la usamos.
    MAX_CONCURRENT = 100 
    
    @@current_count = 0
    @@mutex = Mutex.new

    def self.execute
      # ------------------------------------------------------------------
      # !!! TEMPORALMENTE DESACTIVADO PARA DEPURAR SERVICIOS IPC EN RENDER !!!
      # El código original de limitación de concurrencia está siendo omitido
      # para evitar que el Health Check de Render cause la excepción 500.
      # ------------------------------------------------------------------
      
      # Solo ejecutamos el bloque y retornamos el resultado, bypassando la limitación.
      result = yield 
      result
    end
  end
end