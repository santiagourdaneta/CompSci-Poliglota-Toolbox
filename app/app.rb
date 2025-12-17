require 'thread' 
require 'sinatra'
require_relative '../lib/compsci_core'
require_relative '../lib/math_calculator'
require_relative '../lib/go_crypto'
require_relative '../lib/webarch/middleware/rate_limiter'
require_relative '../lib/rate_limiter'

# Configuración del error
error CompSciToolbox::RateLimitExceeded do
  # 1. Establecer el código de estado HTTP a 503
  status 503 
  
  # 2. Devolver un mensaje claro al cliente
  "Error: Límite de Frecuencia Excedido (Rate Limit Exceeded). Por favor, espera antes de reintentar."
end



# -----------------------------------------------------------------
# CONFIGURACIÓN SINATRA: Definir Rutas de Vistas y Estáticos
# -----------------------------------------------------------------
# 1. Root: Establece el directorio base para la aplicación (donde están las views y public)
#    __dir__ es el directorio actual del archivo (la carpeta 'app/')
set :root, __dir__ 

# 2. Vistas: Busca vistas dentro de 'app/views'
set :views, Proc.new { File.join(root, "views") } 

# 3. Estáticos: Busca archivos estáticos dentro de 'app/public'
set :public_folder, Proc.new { File.join(root, "public") }

# -----------------------------------------------------------------
# 1. CONFIGURACIÓN DE ERRORES GLOBAL DE SINATRA
# -----------------------------------------------------------------
# Esta directiva es la SOLUCIÓN: Captura la excepción RateLimitExceeded
# donde sea que se lance en la app y garantiza una respuesta 503.
error CompSciToolbox::RateLimitExceeded do
  # El método 'status' y 'halt' de Sinatra están implícitos aquí.
  status 503
  'Error 503: Service Unavailable. El servidor está bajo carga máxima y te ha rechazado intencionalmente.'
end

# -----------------------------------------------------------------
# 2. RUTA PRINCIPAL
# -----------------------------------------------------------------
get '/' do

  # Aquí llamas al método que tiene el control de límite
    begin
  # El Rate Limiter envuelve todo el procesamiento políglota
  CompSciToolbox::RateLimiter.execute do
    
    # --- LÓGICA POLÍGLOTA DE SERVICIOS (ÉXITO - HTTP 200) ---

    # === PRUEBA DE DEPURACIÓN ===
        # Verifica si el sistema puede ejecutar Python
        system_check = `which python3` 
        puts "DEBUG: La ruta de Python es: #{system_check}" 
        # === FIN PRUEBA DE DEPURACIÓN ===
    
   # --- DEFINICIÓN DE ENTRADAS ---
    c_plus_input = [5, 2, 8, 1]
    python_input = [[1, 2], [2, 1]]
    go_input = "poliglota"
    
    # --- EJECUCIÓN DE SERVICIOS ---
    sort_result = CompSciToolbox::Core.fast_sort(c_plus_input)
    eigen_result = CompSciToolbox::Math::Calculator.calculate_eigenvalues(python_input)
    go_hash = CompSciToolbox::Security::Crypto.generate_sha256_hash(go_input)
    
    # --- CONSOLIDACIÓN DE LA SALIDA MEJORADA ---
    
    @data_result = "--------------------------------------------------------\n"
    @data_result += "✅ SERVICIO C++ (FFI): Ordenamiento Rápido\n"
    @data_result += "   ENTRADA: #{c_plus_input.inspect}\n"
    @data_result += "   SALIDA: #{sort_result.inspect}\n"
    @data_result += "--------------------------------------------------------\n"
    
    @data_result += "✅ SERVICIO PYTHON (IPC): Cálculo de Eigenvalores\n"
    @data_result += "   ENTRADA: Matriz #{python_input.inspect}\n"
    @data_result += "   SALIDA: #{eigen_result.inspect}\n"
    @data_result += "--------------------------------------------------------\n"
    
    @data_result += "✅ SERVICIO GO (IPC): Generación de Hash SHA-256\n"
    @data_result += "   ENTRADA: Cadena \"#{go_input}\"\n"
    @data_result += "   SALIDA: #{go_hash}\n"
    @data_result += "--------------------------------------------------------"

    erb :index
  end
  rescue => e
      puts "Error inesperado en la ruta: #{e.message}"
      status 500
      "Error interno del servidor: #{e.message}"
    end
end

