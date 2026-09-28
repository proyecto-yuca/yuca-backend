require "test_helper"
require_relative "../../support_alertas"

class Alertas::EvaluarLecturaTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include SupportAlertas

  setup { crear_escenario_alertas }

  test "lectura dentro de todos los rangos no crea alertas" do
    assert_no_difference("Alerta.count") { crear_lectura(60) }
    assert_no_enqueued_jobs only: NotificarAlertaJob
  end

  test "lectura que incumple un evento crea una alerta y encola su correo" do
    assert_enqueued_jobs 1, only: NotificarAlertaJob do
      assert_difference("Alerta.count", 1) { crear_lectura(85) }
    end
    alerta = Alerta.last
    assert_equal [ "alto", "alerta", @optimo.id ], [ alerta.tipo, alerta.severidad, alerta.variable_evento_id ]
    assert_equal [ 40.0, 80.0 ], [ alerta.rango_min.to_f, alerta.rango_max.to_f ]
    assert_equal @finca.id, alerta.finca_id
  end

  test "lectura que incumple dos eventos crea dos alertas" do
    assert_enqueued_jobs 2, only: NotificarAlertaJob do
      assert_difference("Alerta.count", 2) { crear_lectura(95) }
    end
  end

  test "detecta lecturas por debajo del mínimo" do
    crear_lectura(35)
    assert_equal "bajo", Alerta.last.tipo
  end

  test "evento inactivo no dispara" do
    @optimo.update!(activo: false)
    @variable.eventos.reload
    assert_no_difference("Alerta.count") { crear_lectura(85) }
  end

  test "evento sin correo crea la alerta sin encolar correo" do
    @optimo.update!(notificar_email: false, emails: [])
    assert_no_enqueued_jobs(only: NotificarAlertaJob) { crear_lectura(85) }
    assert_equal [ true, "sin_correo" ], [ Alerta.last.notificacion_omitida, Alerta.last.motivo_omision ]
  end

  test "respeta el intervalo por sensor y evento" do
    assert_enqueued_jobs 1, only: NotificarAlertaJob do
      3.times { crear_lectura(85) }
    end
    assert_equal 3, Alerta.count
    assert_equal 2, Alerta.where(notificacion_omitida: true, motivo_omision: "intervalo").count
  end

  test "pasado el intervalo vuelve a notificar" do
    crear_lectura(85)
    Alerta.update_all(created_at: 2.hours.ago)
    assert_enqueued_jobs(1, only: NotificarAlertaJob) { crear_lectura(85) }
  end

  test "otro sensor tiene su propio intervalo" do
    crear_lectura(85)
    otro = @finca.sensores.create!(codigo: "OTRO-1", nombre: "Otro")
    assert_enqueued_jobs 1, only: NotificarAlertaJob do
      Lectura.create!(sensor: otro, variable: @variable, fecha: Date.current, hora_registro: "10:00", valor: 85)
    end
  end

  test "scope fuera_de_rango" do
    dentro = crear_lectura(60)
    fuera  = crear_lectura(85)
    ids = Lectura.where(id: [ dentro.id, fuera.id ]).fuera_de_rango.pluck(:id)
    assert_equal [ fuera.id ], ids
  end
end
