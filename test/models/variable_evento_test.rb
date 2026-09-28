require "test_helper"

class VariableEventoTest < ActiveSupport::TestCase
  setup do
    @variable = Variable.create!(nombre: "Humedad evento test", unidad: "%", decimales: 1)
  end

  def evento(attrs = {})
    @variable.eventos.build({ nombre: "Rango", rango_min: 40, rango_max: 80, emails: [ "a@yuca.com" ] }.merge(attrs))
  end

  test "evaluar devuelve bajo, alto o nil" do
    e = evento
    assert_equal "bajo", e.evaluar(39.9)
    assert_equal "alto", e.evaluar(80.1)
    assert_nil e.evaluar(40)
    assert_nil e.evaluar(80)
  end

  test "acepta solo un límite" do
    assert evento(rango_min: nil).valid?
    assert_equal "alto", evento(rango_min: nil).evaluar(81)
    assert_nil evento(rango_min: nil).evaluar(-1000)
  end

  test "exige al menos un límite" do
    e = evento(rango_min: nil, rango_max: nil)
    assert_not e.valid?
    assert_includes e.errors[:rango_min], "debe definir un mínimo o un máximo"
  end

  test "el mínimo debe ser menor que el máximo" do
    e = evento(rango_min: 80, rango_max: 40)
    assert_not e.valid?
    assert_includes e.errors[:rango_min], "debe ser menor que el máximo"
  end

  test "con correo activo exige al menos un correo" do
    e = evento(emails: [])
    assert_not e.valid?
    assert_includes e.errors[:emails], "debe tener al menos un correo si la notificación por correo está activa"
  end

  test "sin correo activo no exige correos" do
    assert evento(notificar_email: false, emails: []).valid?
  end

  test "normaliza, quita duplicados y valida correos" do
    e = evento(emails: [ " Agronomo@Yuca.com ", "agronomo@yuca.com", "", "mal@" ])
    assert_not e.valid?
    assert_equal [ "agronomo@yuca.com", "mal@" ], e.emails
    assert_includes e.errors[:emails], "correo inválido: mal@"
  end

  test "máximo 10 correos" do
    e = evento(emails: (1..11).map { |i| "c#{i}@yuca.com" })
    assert_not e.valid?
    assert_includes e.errors[:emails], "no puede tener más de 10 correos"
  end

  test "severidad válida" do
    assert_not evento(severidad: "grave").valid?
  end
end
