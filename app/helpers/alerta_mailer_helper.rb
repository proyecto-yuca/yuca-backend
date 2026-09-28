module AlertaMailerHelper
  MESES = %w[enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre].freeze
  MESES_CORTOS = %w[ene feb mar abr may jun jul ago sep oct nov dic].freeze

  SEVERIDADES = {
    "critico" => {
      etiqueta: "CRÍTICO", acento: "#B42318", fondo: "#FEF3F2", borde: "#FECDCA", profundo: "#7a271a"
    },
    "alerta" => {
      etiqueta: "ALERTA", acento: "#B54708", fondo: "#FFFAEB", borde: "#FEDF89", profundo: "#7a2e0e"
    }
  }.freeze

  def severidad_tokens(severidad)
    SEVERIDADES.fetch(severidad.to_s, SEVERIDADES["alerta"])
  end

  # Separador de miles con espacio fino ("112 000"), para no confundirlo con el punto decimal.
  def numero(valor, variable)
    ActiveSupport::NumberHelper.number_to_delimited(format("%.#{variable.decimales}f", valor.to_d), delimiter: "\u202F")
  end

  # "95.2 %", "32.1 °C", "120000 lux"
  def valor_con_unidad(valor, variable)
    "#{numero(valor, variable)} #{variable.unidad}".strip
  end

  # "+5.2 %" si está por encima del máximo, "−3.0 °C" si está por debajo del mínimo.
  def desviacion(alerta)
    if alerta.tipo == "alto"
      "+#{valor_con_unidad(alerta.valor - alerta.rango_max, alerta.variable)}"
    else
      "−#{valor_con_unidad(alerta.rango_min - alerta.valor, alerta.variable)}"
    end
  end

  def descripcion_tipo(alerta)
    alerta.tipo == "alto" ? "por encima del máximo" : "por debajo del mínimo"
  end

  # "30 % – 90 %", "≥ 30 %", "≤ 90 %"
  def rango_texto(alerta)
    v = alerta.variable
    if alerta.rango_min && alerta.rango_max
      "#{valor_con_unidad(alerta.rango_min, v)} – #{valor_con_unidad(alerta.rango_max, v)}"
    elsif alerta.rango_min
      "≥ #{valor_con_unidad(alerta.rango_min, v)}"
    else
      "≤ #{valor_con_unidad(alerta.rango_max, v)}"
    end
  end

  # "28 de septiembre de 2026, 14:00"
  def fecha_hora_larga(lectura)
    f = lectura.fecha
    "#{f.day} de #{MESES[f.month - 1]} de #{f.year}, #{lectura.hora_registro}"
  end

  # "28 sep 2026 · 14:00"
  def fecha_hora_corta(lectura)
    f = lectura.fecha
    "#{f.day} #{MESES_CORTOS[f.month - 1]} #{f.year} · #{lectura.hora_registro}"
  end

  # Zonas de la barra de rango: [{ ancho:, color:, etiqueta:, activa: }]
  def zonas_rango(alerta, tokens)
    inactiva = "#f2e9df"
    zonas = []
    anchos = if alerta.rango_min && alerta.rango_max then [ 22, 56, 22 ]
    elsif alerta.rango_min then [ 30, 70 ]
    else [ 70, 30 ]
    end

    if alerta.rango_min
      activa = alerta.tipo == "bajo"
      zonas << { ancho: anchos.shift, color: activa ? tokens[:acento] : inactiva, activa: activa, lado: :bajo,
                 etiqueta: activa ? "▼ #{valor_con_unidad(alerta.valor, alerta.variable)}" : "Bajo" }
    end
    zonas << { ancho: anchos.shift, color: "#a8d3a5", activa: false, lado: :permitido, etiqueta: rango_texto(alerta) }
    if alerta.rango_max
      activa = alerta.tipo == "alto"
      zonas << { ancho: anchos.shift, color: activa ? tokens[:acento] : inactiva, activa: activa, lado: :alto,
                 etiqueta: activa ? "▲ #{valor_con_unidad(alerta.valor, alerta.variable)}" : "Alto" }
    end
    zonas
  end
end
