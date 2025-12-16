require_relative '../spec_helper' 
# Esto le dice a RSpec: "¡Detente! Antes de seguir, ve a un directorio arriba y carga 'spec_helper.rb'"
RSpec.describe RateLimiter do
  let(:ip_address) { '192.168.1.100' }

  # Aseguramos que el estado de conteo se reinicie para cada prueba
  before do
    # Usamos .class_variable_set solo si la variable es @@request_counts
    # RateLimiter.class_variable_set(:@@request_counts, {})
  end

  it 'permite las primeras 5 solicitudes para una IP' do
    (1..5).each do |i|
      expect(RateLimiter.call(ip_address)).to be_truthy, 
        "Debería permitir la solicitud ##{i}"
    end
  end

  it 'bloquea la sexta solicitud para una IP' do
    5.times { RateLimiter.call(ip_address) }
    expect(RateLimiter.call(ip_address)).to be_falsey
  end

  it 'mantiene contadores separados para diferentes IPs' do
    ip_a = '10.0.0.1'
    ip_b = '10.0.0.2'
    
    5.times { RateLimiter.call(ip_a) }
    expect(RateLimiter.call(ip_b)).to be_truthy
    expect(RateLimiter.call(ip_a)).to be_falsey
  end
end