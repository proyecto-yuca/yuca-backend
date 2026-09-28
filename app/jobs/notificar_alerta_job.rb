class NotificarAlertaJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(alerta_id)
    alerta = Alerta.includes(:variable_evento, :variable, :lectura, :finca, sensor: :cultivo).find_by(id: alerta_id)
    return if alerta.nil? || alerta.email_enviado_at.present?

    # La lista se lee al momento del envío: si la editaron después de disparar, vale la nueva.
    emails = alerta.variable_evento.emails
    if emails.empty?
      return alerta.update!(notificacion_omitida: true, motivo_omision: "sin_destinatarios")
    end

    AlertaMailer.with(alerta: alerta).fuera_de_rango(emails).deliver_now
    alerta.update!(email_enviado_at: Time.current, emails_enviados: emails, error_envio: nil)
  rescue StandardError => e
    alerta&.update_column(:error_envio, "#{e.class}: #{e.message}".truncate(1000))
    raise
  end
end
