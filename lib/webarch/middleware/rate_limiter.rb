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
          # 1. Obtener la IP del cliente de forma segura.
                # Priorizar X-Forwarded-For (XFF) si estamos detrás de un proxy/load balancer.
                # Si no existe XFF, usar REMOTE_ADDR (IP del último nodo que tocó el servidor).
                
                # Obtener IP del encabezado X-Forwarded-For si existe, 
                # tomando la primera IP de la lista (que es la del cliente original).
                if env['HTTP_X_FORWARDED_FOR']
                  client_ip = env['HTTP_X_FORWARDED_FOR'].split(',').first.strip
                else
                  # Usar REMOTE_ADDR como fallback directo si no hay proxy
                  client_ip = env['REMOTE_ADDR']
                end
                
                # Manejo de error: si la IP sigue siendo nil o está vacía, debemos abortar o registrar.
                if client_ip.nil? || client_ip.empty?
                  # Si la IP es indeterminada, en lugar de usar '127.0.0.1', 
                  # devolvemos un error 400 o un log, ya que el Rate Limiter no puede funcionar.
                  # Para fines de demostración, permitiremos el acceso pero con una advertencia en el log.
                  # En producción, esto debería ser un error 500 o 403.
                  puts "[WARNING] No se pudo determinar la IP del cliente para Rate Limiting." 
                  client_ip = 'unknown_ip_fallback' # Mejor usar un string que represente el error
                end
                
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
