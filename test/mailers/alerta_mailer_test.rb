require "test_helper"
require_relative "../support_alertas"

class AlertaMailerTest < ActionMailer::TestCase
  include SupportAlertas

  setup do
    crear_escenario_alertas
    lectura = crear_lectura(95.2)
    @alerta = Alerta.find_by!(lectura: lectura, variable_evento: @critico)
  end

  test "asunto, destinatarios y contenido" do
    correo = AlertaMailer.with(alerta: @alerta).fuera_de_rango([ "gerencia@yuca.com" ])

    assert_equal [ "gerencia@yuca.com" ], correo.to
    assert_equal "[CRÍTICO] Crítica — Lote Sur, Agrícola Test", correo.subject

    html = correo.html_part.body.to_s
    assert_includes html, "95.2"
    assert_includes html, "30.0 % – 90.0 %"
    assert_includes html, "+5.2 %"
    assert_includes html, "/dashboard/lecturas?finca=#{@finca.id}&amp;sensor=#{@sensor.id}"

    texto = correo.text_part.body.to_s
    assert_includes texto, "Rango permitido:   30.0 % – 90.0 %"
  end

  test "lectura por debajo del mínimo" do
    lectura = crear_lectura(25)
    alerta  = Alerta.find_by!(lectura: lectura, variable_evento: @critico)
    html = AlertaMailer.with(alerta: alerta).fuera_de_rango([ "a@yuca.com" ]).html_part.body.to_s
    assert_includes html, "Por debajo del mínimo"
    assert_includes html, "−5.0 %"
  end
end
