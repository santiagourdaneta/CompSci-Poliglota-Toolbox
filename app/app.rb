require 'sinatra/base'
require_relative '../lib/compsci_core'  # Requerimos el archivo central de la librería que, a su vez, carga el RateLimiter
require_relative '../lib/math_calculator' # Carga el módulo CompSciToolbox::Math::Calculator (Python)

class PoliglotaApp < Sinatra::Base
  # Configuración para forzar SSR (Server Side Rendering)
  set :views, File.expand_path('../views', __FILE__)

  # Indicamos a Sinatra dónde buscar archivos estáticos (CSS, JS, imágenes).
  set :public_folder, File.expand_path('../public', __FILE__)
  
  # Habilitar el manejo de archivos estáticos
  enable :static
  
  # === Middleware de Seguridad  ===

  use CompSciToolbox::WebArch::Middleware::RateLimiter 
  
  # Endpoint principal que demuestra el HTML-First
  get '/' do
    
   #Datos iniciales desordenados en Ruby
   unsorted_data = [99, 12, 5, 23, 1]
   
   #Delegamos el ordenamiento de alto rendimiento a la función de C++ via FFI
   sorted_data_cpp = CompSciToolbox::Algorithms.fast_sort(unsorted_data.dup) 

   # --- DELEGACIÓN A PYTHON ---

   # 1. Definir la matriz para el cálculo
   matrix = [[4.0, -2.0], [1.0, 1.0]]
   # 2. Llamar al servicio de Python
   eigenvalues = CompSciToolbox::Math::Calculator.calculate_eigenvalues(matrix)

   @title = "Poliglota CompSci Toolbox"
   @data_result = "Datos sin ordenar (Ruby): #{unsorted_data.join(', ')}\n"
   @data_result += "Datos ordenados (C++/FFI): #{sorted_data_cpp.join(', ')}\n\n"
   @data_result += "Matriz de Entrada (Ruby): #{matrix.to_s}\n"
   @data_result += "Eigenvalores (Python/NumPy): #{eigenvalues.to_s}"
   # ------------------------------------
    
    # Renderizamos la vista HTML-First
    erb :index 
  end

end

