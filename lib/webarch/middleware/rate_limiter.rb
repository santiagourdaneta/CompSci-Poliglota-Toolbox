module CompSciToolbox
  module WebArch
    module Middleware
      class RateLimiter
        # Parámetros del algoritmo
        MAX_REQUESTS = 10
        WINDOW_SECONDS = 60
        
        # Almacenamiento en memoria para rastrear solicitudes por IP.
        @@request_counts = {}

        def initialize(app)
          @app = app
        end
        
        # El método call es requerido para middleware de Rack/Sinatra
        def call(env)
          # 1. Obtener la IP del cliente 
          client_ip = env['REMOTE_ADDR'] || '127.0.0.1' 
          current_time = Time.now.to_i # Tiempo actual en segundos

          # 2. Limpiar entradas antiguas (Contador Fijo)
          # Esto evita que la memoria se llene.
          clean_old_entries(current_time)

          # 3. Obtener el registro de la IP actual
          ip_record = @@request_counts[client_ip] || { count: 0, reset_time: current_time + WINDOW_SECONDS }

          # 4. Verificar el límite
          if current_time < ip_record[:reset_time] && ip_record[:count] >= MAX_REQUESTS
            # Límite excedido: Devolver un error 429 (Too Many Requests)
            puts "--- [SEGURIDAD - BLOQUEADO] IP #{client_ip} ha excedido el Rate Limit."
            return [429, { 'Content-Type' => 'text/plain', 'Retry-After' => ip_record[:reset_time] - current_time.to_s }, ["Too Many Requests (Rate Limit Exceeded)"]]
          end

          # 5. Incrementar el contador y actualizar el registro
          ip_record[:count] += 1
          # Si el tiempo de reinicio expiró, reiniciamos el contador y la ventana
          if current_time >= ip_record[:reset_time]
            ip_record[:count] = 1
            ip_record[:reset_time] = current_time + WINDOW_SECONDS
          end
          
          @@request_counts[client_ip] = ip_record
          puts "--- [Seguridad] IP #{client_ip} | Solicitudes: #{ip_record[:count]}/#{MAX_REQUESTS} | Reset en: #{ip_record[:reset_time] - current_time}s"

          # 6. Si no hay bloqueo, pasar la solicitud a la aplicación
          @app.call(env)
        end
        
        # Método para limpiar entradas 
        private
        def clean_old_entries(current_time)
          @@request_counts.delete_if do |ip, record|
            record[:reset_time] < current_time - WINDOW_SECONDS * 2 # Limpiamos registros muy viejos
          end
        end
      end
    end
  end
end
