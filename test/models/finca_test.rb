require "test_helper"

class FincaTest < ActiveSupport::TestCase
  AREA = [
    { "lat" => "4.0", "lng" => "-74.0" },
    { "lat" => "4.0", "lng" => "-73.0" },
    { "lat" => "5.0", "lng" => "-73.0" },
    { "lat" => "5.0", "lng" => "-74.0" }
  ].freeze

  setup do
    user = User.create!(email: "finca-test@yuca.com", password: "password123")
    @finca = Finca.create!(
      user: user, nombre: "Finca Test", area: 10, departamento: "Cundinamarca", municipio: "Silvania",
      dueno_nombre: "Dueño", dueno_tipo_documento: "CC", dueno_numero_documento: "123",
      dueno_email: "dueno@yuca.com", dueno_telefono: "3000000000", puntos_ubicacion: AREA
    )
  end

  test "no permite más de 4 puntos" do
    @finca.puntos_ubicacion = AREA + [ { "lat" => "4.5", "lng" => "-73.5" } ]
    assert_not @finca.valid?
    assert_includes @finca.errors[:puntos_ubicacion], "no puede tener más de 4 puntos"
  end

  test "rechaza puntos no numéricos" do
    @finca.puntos_ubicacion = [ { "lat" => "abc", "lng" => "-73.5" } ]
    assert_not @finca.valid?
    assert_includes @finca.errors[:puntos_ubicacion], "punto 1 debe tener lat y lng numéricos"
  end

  test "contiene_punto? detecta puntos dentro y fuera" do
    assert @finca.contiene_punto?(4.5, -73.5)
    assert_not @finca.contiene_punto?(6.0, -73.5)
  end

  test "no permite achicar el área dejando un cultivo fuera" do
    @finca.cultivos.create!(nombre: "Lote", puntos_ubicacion: [ { "lat" => "4.9", "lng" => "-73.1" } ])
    @finca.puntos_ubicacion = [
      { "lat" => "4.0", "lng" => "-74.0" },
      { "lat" => "4.0", "lng" => "-73.5" },
      { "lat" => "4.5", "lng" => "-73.5" },
      { "lat" => "4.5", "lng" => "-74.0" }
    ]
    assert_not @finca.valid?
    assert_includes @finca.errors[:puntos_ubicacion], "el cultivo Lote quedaría fuera del área de la finca"
  end
end
