class AlertaMailer < ApplicationMailer
  include AlertaMailerHelper
  helper AlertaMailerHelper
  layout false

  # AlertaMailer.with(alerta: alerta).fuera_de_rango(emails)
  def fuera_de_rango(emails)
    @alerta   = params[:alerta]
    @evento   = @alerta.variable_evento
    @variable = @alerta.variable
    @lectura  = @alerta.lectura
    @sensor   = @alerta.sensor
    @cultivo  = @sensor.cultivo
    @finca    = @alerta.finca
    @url_lecturas = "#{ENV.fetch("FRONTEND_URL", "http://localhost:5173")}/dashboard/lecturas?finca=#{@finca.id}&sensor=#{@sensor.id}"

    lugar = [ @cultivo&.nombre || @sensor.nombre, @finca.nombre ].join(", ")
    etiqueta = severidad_tokens(@alerta.severidad)[:etiqueta]

    mail(to: emails, subject: "[#{etiqueta}] #{@evento.nombre} — #{lugar}")
  end
end
