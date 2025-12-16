# 1. Cargar Bundler y Gems de prueba 
require 'bundler/setup'
Bundler.require(:default, :test) 

# --- Configuración de la Ruta de Carga ($LOAD_PATH) ---
# Usamos File.expand_path para calcular la ruta absoluta al directorio 'lib'
# '__dir__' es 'spec/'. Subimos un nivel ('..') para llegar a la raíz.
lib_path = File.expand_path('../lib', __dir__) 

# Asegura que el directorio 'lib' esté en la ruta de búsqueda
$LOAD_PATH.unshift(lib_path)

# --- Carga Explícita de Clases Principales ---
require 'webarch/middleware/rate_limiter'
require 'math_calculator'
require 'go_crypto'
require 'open3' 

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  # Otras configuraciones de RSpec...
end