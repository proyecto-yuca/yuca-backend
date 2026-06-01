# bin/rails runner 'load Rails.root.join("db/seeds/iot_credentials.rb")'

puts "🔌 Credenciales IoT de prueba:"
Finca.order(:id).limit(2).each_with_index do |finca, idx|
  client_id = "iot-demo-#{idx + 1}"
  secret_id = "iot-secret-demo-#{idx + 1}"

  credential = finca.iot_credential || finca.build_iot_credential
  credential.client_id = client_id
  credential.secret_id = secret_id
  credential.active = true
  credential.save!

  puts "   finca #{finca.id}: #{client_id} / #{secret_id}"
end
puts ""
