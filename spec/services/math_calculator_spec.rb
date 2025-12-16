require_relative '../spec_helper' 
# Esto le dice a RSpec: "¡Detente! Antes de seguir, ve a un directorio arriba y carga 'spec_helper.rb'"
RSpec.describe MathCalculator do

  describe '#quick_sort_c' do
    # Prueba de la mitigación de Integer Overflow/malloc(0) con calloc.
    it 'devuelve un array vacío para un tamaño de entrada de 0' do
      # Si C++ devuelve NULL (por calloc(0)), Ruby lo mapea a [].
      input_data = [5, 2, 8]
      sorted_result = MathCalculator.quick_sort_c(input_data, 0)
      
      expect(sorted_result).to eq([])
    end
    
    it 'devuelve un array vacío para un tamaño de entrada negativo' do
      input_data = [5, 2, 8]
      sorted_result = MathCalculator.quick_sort_c(input_data, -5)
      
      expect(sorted_result).to eq([])
    end
    
    it 'ordena correctamente un array válido' do
      input_data = [5, 2, 8, 1, 9]
      sorted_result = MathCalculator.quick_sort_c(input_data, 5)
      
      expect(sorted_result).to eq([1, 2, 5, 8, 9])
    end
  end
end