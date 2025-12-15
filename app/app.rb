require 'sinatra/base'
require_relative '../lib/compsci_core'
require_relative '../lib/math_calculator'
require_relative '../lib/go_crypto'
require_relative '../lib/webarch/middleware/rate_limiter'

# Clase principal de la aplicación Rack/Sinatra que orquesta los servicios políglotas
class PoliglotaApp < Sinatra::Base
  # Configuración para forzar SSR (Server Side Rendering)
  set :views, File.expand_path('views', __dir__)

  # Indicamos a Sinatra dónde buscar archivos estáticos (CSS, JS, imágenes).
  set :public_folder, File.expand_path('public', __dir__)

  # Habilitar el manejo de archivos estáticos
  enable :static

  # === Middleware de Seguridad  ===

  use CompSciToolbox::WebArch::Middleware::RateLimiter

  # Endpoint principal que demuestra el HTML-First
  get '/' do
    # --- 1. Servicio C++ (FFI) ---
    data_array = [8, 3, 1, 6, 2, 7, 4, 5]
    sorted_data = CompSciToolbox::Core.fast_sort(data_array)

    # --- 2. Servicio Python (IPC) ---
    matrix = [[1, 2], [3, 4]]
    eigenvalues = CompSciToolbox::Math::Calculator.calculate_eigenvalues(matrix)

    # --- 3. Servicio Go (IPC/Shell) ---
    token_data = 'ElTokenDePrueba2025!'
    sha256_hash = CompSciToolbox::Security::Crypto.generate_sha256_hash(token_data)

    # --- Compilación de Resultados ---
    @data_result = "--- Resultados del Sistema Políglota ---\n\n"

    @data_result += "1. C++ (FFI) - Ordenamiento Rápido:\n"
    @data_result += "   Datos sin ordenar (Ruby) Original: #{data_array.inspect}\n"
    @data_result += "   Datos ordenados (C++/FFI) Ordenado: #{sorted_data.inspect}\n\n"

    @data_result += "2. Python (NumPy) - Cálculo de Eigenvalores:\n"
    @data_result += "   Matriz de Entrada (Ruby): #{matrix.inspect}\n"
    @data_result += "   Eigenvalores (Python/NumPy/JSON): #{eigenvalues.inspect}\n\n"

    @data_result += "3. Go (SHA-256) - Servicio Criptográfico:\n"
    # Usamos el resultado limpio que viene de Go (una sola línea de texto)
    @data_result += "   #{sha256_hash}\n"
    # ------------------------------------

    # Renderizamos la vista HTML-First
    erb :index
  end
end
