require "test_helper"
require_relative "../support_alertas"

class NotificarAlertaJobTest < ActiveJob::TestCase
  include SupportAlertas

  setup do
    crear_escenario_alertas
    ActionMailer::Base.deliveries.clear
    @lectura = crear_lectura(95)
    @alerta  = Alerta.find_by!(lectura: @lectura, variable_evento: @critico)
  end

  test "envía el correo a toda la lista del evento y lo registra" do
    NotificarAlertaJob.perform_now(@alerta.id)

    correo = ActionMailer::Base.deliveries.last
    assert_equal [ "agronomo@yuca.com", "gerencia@yuca.com" ], correo.to
    assert_match "[CRÍTICO] Crítica", correo.subject
    @alerta.reload
    assert_not_nil @alerta.email_enviado_at
    assert_equal [ "agronomo@yuca.com", "gerencia@yuca.com" ], @alerta.emails_enviados
  end

  test "no reenvía una alerta ya enviada" do
    NotificarAlertaJob.perform_now(@alerta.id)
    assert_no_difference("ActionMailer::Base.deliveries.size") { NotificarAlertaJob.perform_now(@alerta.id) }
  end

  test "usa la lista vigente al momento del envío" do
    @critico.update!(emails: [ "nuevo@yuca.com" ])
    NotificarAlertaJob.perform_now(@alerta.id)
    assert_equal [ "nuevo@yuca.com" ], ActionMailer::Base.deliveries.last.to
  end

  test "sin destinatarios marca la alerta como omitida" do
    @critico.update!(notificar_email: false, emails: [])
    NotificarAlertaJob.perform_now(@alerta.id)
    assert_empty ActionMailer::Base.deliveries
    assert_equal "sin_destinatarios", @alerta.reload.motivo_omision
  end
end
