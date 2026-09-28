require "test_helper"

class CultivoTest < ActiveSupport::TestCase
  setup do
    user = User.create!(email: "cultivo-test@yuca.com", password: "password123")
    @finca = Finca.create!(
      user: user, nombre: "Finca Test", area: 10, departamento: "Cundinamarca", municipio: "Silvania",
      dueno_nombre: "Dueño", dueno_tipo_documento: "CC", dueno_numero_documento: "123",
      dueno_email: "dueno@yuca.com", dueno_telefono: "3000000000",
      puntos_ubicacion: [
        { "lat" => "4.0", "lng" => "-74.0" },
        { "lat" => "4.0", "lng" => "-73.0" },
        { "lat" => "5.0", "lng" => "-73.0" },
        { "lat" => "5.0", "lng" => "-74.0" }
      ]
    )
  end

  test "acepta puntos dentro de la finca" do
    cultivo = @finca.cultivos.build(nombre: "Lote", puntos_ubicacion: [
      { "lat" => "4.2", "lng" => "-73.8" },
      { "lat" => "4.2", "lng" => "-73.2" },
      { "lat" => "4.8", "lng" => "-73.5" }
    ])
    assert cultivo.valid?
  end

  test "rechaza puntos fuera de la finca" do
    cultivo = @finca.cultivos.build(nombre: "Lote", puntos_ubicacion: [
      { "lat" => "4.2", "lng" => "-73.8" },
      { "lat" => "6.0", "lng" => "-73.5" }
    ])
    assert_not cultivo.valid?
    assert_includes cultivo.errors[:puntos_ubicacion], "punto 2 está fuera del área de la finca"
  end

  test "sin área de finca no valida contención" do
    @finca.update!(puntos_ubicacion: [])
    cultivo = @finca.cultivos.build(nombre: "Lote", puntos_ubicacion: [ { "lat" => "10.0", "lng" => "-60.0" } ])
    assert cultivo.valid?
  end

  test "no permite más de 4 puntos" do
    cultivo = @finca.cultivos.build(nombre: "Lote", puntos_ubicacion: Array.new(5) { { "lat" => "4.5", "lng" => "-73.5" } })
    assert_not cultivo.valid?
    assert_includes cultivo.errors[:puntos_ubicacion], "no puede tener más de 4 puntos"
  end
end
