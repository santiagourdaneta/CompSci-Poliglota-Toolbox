# frozen_string_literal: true

# Carga las dependencias del entorno
require 'bundler/setup'

# Carga la aplicación principal (PoliglotaApp)
require_relative 'app/app'

# Monta la aplicación para que Puma/Rack la ejecute
run PoliglotaApp
