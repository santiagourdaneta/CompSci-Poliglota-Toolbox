# frozen_string_literal: true

# Cargar el entorno y las dependencias (Bundler)
require 'bundler'
Bundler.require

# --- Añadir el directorio 'app' a la ruta de búsqueda de Ruby ---
$LOAD_PATH.unshift(File.expand_path('./app'))

# Cargar tu aplicación Sinatra (app.rb)
require 'app'

# Ejecutar la aplicación cargada
run Sinatra::Application
