# frozen_string_literal: true

# lib/webarch/middleware/rate_limiter.rb

module CompSciToolbox
  module WebArch
    module Middleware
      # Implementa una capa de Rate Limiting (limitación de tasa) básica
      # basada en la IP del cliente para proteger contra DDoS simples o fuerza bruta.
      class RateLimiter
        # Uso de variable de instancia de clase para el almacenamiento concurrente.
        # Esto reemplaza a la problemática @@request_counts.
        def self.request_counts
          @request_counts ||= {}
        end

        MAX_REQUESTS = 10
        RESET_TIME_SECONDS = 60

        # Inicializador estándar de Rack
        def initialize(app)
          @app = app
        end

        # El método call se vuelve el punto de orquestación (más limpio)
        def call(env)
          client_ip = get_client_ip(env)
          current_time = Time.now.to_i
          ip_record = self.class.request_counts[client_ip]

          # 1. Limpieza y reinicio
          if ip_record && ip_record[:reset_time] < current_time
            self.class.request_counts.delete(client_ip)
            ip_record = nil
          end

          # 2. Inicialización
          unless ip_record
            ip_record = { count: 0, reset_time: current_time + RESET_TIME_SECONDS }
            self.class.request_counts[client_ip] = ip_record
          end

          # 3. Verificación de límite
          if ip_record[:count] >= MAX_REQUESTS
            return too_many_requests_response(client_ip, ip_record[:reset_time], current_time)
          end

          # 4. Procesar solicitud
          ip_record[:count] += 1

          # Registro de actividad (para la terminal)
          puts "--- [Seguridad] IP #{client_ip} | Solicitudes: #{ip_record[:count]}/#{MAX_REQUESTS} | Reset en: #{ip_record[:reset_time] - current_time}s"

          @app.call(env)
        end

        private

        # Mueve la lógica compleja de extracción de IP (XFF) fuera del método call.
        def get_client_ip(env)
          # Si existe X-Forwarded-For, tomar la primera IP (el cliente original).
          if env['HTTP_X_FORWARDED_FOR']
            env['HTTP_X_FORWARDED_FOR'].split(',').first.strip
          else
            # Usar la IP directa si no hay un proxy (REMOTE_ADDR)
            env['REMOTE_ADDR']
          end
        end

        # Genera la respuesta HTTP 429 cuando se excede el límite.
        def too_many_requests_response(client_ip, reset_time, current_time)
          puts "!!! [SEGURIDAD/BLOQUEADO] IP #{client_ip} ha excedido el límite de tasa."
          [429,
           { 'Content-Type' => 'text/plain', 'Retry-After' => (reset_time - current_time).to_s },
           ['Too Many Requests (Rate Limit Exceeded)']]
        end
      end
    end
  end
end
