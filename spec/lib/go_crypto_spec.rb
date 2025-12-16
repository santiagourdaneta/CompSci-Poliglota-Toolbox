require_relative '../spec_helper' 
# Esto le dice a RSpec: "¡Detente! Antes de seguir, ve a un directorio arriba y carga 'spec_helper.rb'"
RSpec.describe GoCrypto do
  describe '.execute_command_safe' do
    let(:safe_input) { 'input_data' }
    
    # Mockeamos Open3 para no tener que ejecutar el binario Go real
    it 'ejecuta el comando con argumentos como un array para prevenir inyección' do
      # Verificamos que se llama con dos argumentos: el binario y el input (Array de argumentos)
      expect(Open3).to receive(:capture3).with('go_binary', safe_input).and_return(['output', '', 0])
      
      # Nota: GoCrypto.execute_command_safe debe ser el método que usa internamente Open3.capture3
      GoCrypto.execute_command_safe(safe_input)
    end
    
    it 'trata la entrada maliciosa como argumento, no como comando de shell' do
      malicious_input = 'data; rm -rf /' 
      
      # Esperamos que todo el string malicioso sea el segundo argumento del array.
      expect(Open3).to receive(:capture3).with('go_binary', malicious_input).and_return(['output', '', 0])
      
      expect { GoCrypto.execute_command_safe(malicious_input) }.not_to raise_error
    end
  end
end