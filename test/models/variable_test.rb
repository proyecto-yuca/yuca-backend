require "test_helper"

class VariableTest < ActiveSupport::TestCase
  setup do
    @variable = Variable.create!(nombre: "Temperatura variable test", unidad: "°C", decimales: 1)
  end

  test "crea, edita y borra eventos con eventos_attributes" do
    @variable.update!(eventos_attributes: [
      { nombre: "Óptimo", rango_min: 10, rango_max: 33, emails: [ "a@yuca.com" ] },
      { nombre: "Crítico", severidad: "critico", rango_min: 5, rango_max: 38, emails: [ "b@yuca.com" ] }
    ])
    assert_equal 2, @variable.eventos.count

    optimo = @variable.eventos.find_by(nombre: "Óptimo")
    critico = @variable.eventos.find_by(nombre: "Crítico")
    @variable.update!(eventos_attributes: [
      { id: optimo.id, rango_max: 30 },
      { id: critico.id, _destroy: true }
    ])
    assert_equal [ 30.0 ], @variable.reload.eventos.map { |e| e.rango_max.to_f }
  end

  test "rechaza dos eventos con el mismo nombre en el mismo request" do
    @variable.assign_attributes(eventos_attributes: [
      { nombre: "Rango", rango_max: 30, emails: [ "a@yuca.com" ] },
      { nombre: "rango", rango_max: 40, emails: [ "a@yuca.com" ] }
    ])
    assert_not @variable.valid?
    assert_includes @variable.errors[:eventos], "no puede tener dos eventos con el mismo nombre"
  end

  test "errores de eventos llevan el índice" do
    @variable.assign_attributes(eventos_attributes: [ { nombre: "Sin correo", rango_max: 30, emails: [] } ])
    assert_not @variable.valid?
    assert @variable.errors.key?(:"eventos[0].emails")
  end

  test "estado_para y eventos_disparados" do
    assert_nil @variable.estado_para(50)

    @variable.eventos.create!(nombre: "Óptimo", rango_min: 10, rango_max: 33, emails: [ "a@yuca.com" ])
    @variable.eventos.create!(nombre: "Crítico", severidad: "critico", rango_min: 5, rango_max: 38, emails: [ "a@yuca.com" ])
    @variable.eventos.create!(nombre: "Apagado", rango_max: 1, emails: [ "a@yuca.com" ], activo: false)
    @variable.eventos.reload

    assert_equal "normal",  @variable.estado_para(20)
    assert_equal "alerta",  @variable.estado_para(35)
    assert_equal "critico", @variable.estado_para(40)
    assert_equal [ %w[Óptimo alto], %w[Crítico alto] ],
                 @variable.eventos_disparados(40).map { |e, tipo| [ e.nombre, tipo ] }
  end
end
