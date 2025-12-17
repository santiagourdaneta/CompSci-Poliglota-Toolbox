# lib/rate_limiter.rb

require 'thread'

# 1. Clase de excepción pública: Usada para señalar a Sinatra que devuelva 503
class RateLimitExceeded < StandardError; end 

module CompSciToolbox
  class RateLimiter

    # Límite de ejecución concurrente.
    MAX_CONCURRENT = 100 
    
    @@current_count = 0
    @@mutex = Mutex.new

    def self.execute
      can_execute = false
      result = nil

      @@mutex.synchronize do
        if @@current_count < MAX_CONCURRENT
          @@current_count += 1
          can_execute = true
        end
      end

      if can_execute
        begin
          result = yield 
        ensure
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