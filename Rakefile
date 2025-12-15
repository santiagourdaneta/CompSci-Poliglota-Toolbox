# frozen_string_literal: true

# Rakefile

require 'rake/clean' # Útil para tareas de limpieza (como .so)
require 'rake/file_utils'

task default: [:compile_cpp]

task :compile_cpp do
  puts 'Compilando C++ a services/cpp_fast_algs/sorting.dll (Enlace Estático)...'
  # Forzamos la salida a .dll y usamos la compilación estática
  sh 'g++ -shared -static-libgcc -static-libstdc++ services/cpp_fast_algs/sorting.cpp -o services/cpp_fast_algs/sorting.dll'
end
