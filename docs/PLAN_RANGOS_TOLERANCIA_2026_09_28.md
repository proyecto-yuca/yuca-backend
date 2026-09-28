# Plan: Eventos de tolerancia por variable con notificación por correo

> **Estado: implementado el 2026-09-28** (backend y frontend), probado en local. Detalle en [SESION_2026_09_28.md](./SESION_2026_09_28.md#parte-2--eventos-de-tolerancia-y-alertas-por-correo). Quedan abiertos los GAPs del final.

## Objetivo

Cada **variable** (Humedad, Temperatura, Luminosidad, …) puede tener **uno o varios eventos**. Cada evento define:

- un **rango de tolerancia** (mínimo / máximo),
- si avisa por **correo**,
- la **lista de correos** que reciben el aviso.

Cuando llega una lectura fuera del rango de un evento:

1. La lectura se marca con los eventos que disparó (en la API y en el frontend).
2. Se registra una **alerta** por cada evento disparado.
3. Se envía el correo a la lista del evento.

Aplica tanto a lecturas manuales (`POST .../lecturas`) como a las que llegan por IoT (`POST /api/v1/iot/lecturas_sensor/sync`).

**Ejemplo — variable Humedad (%):**

| Evento | Severidad | Rango permitido | Correos |
|--------|-----------|-----------------|---------|
| Humedad fuera de óptimo | alerta | 40 – 80 | `agronomo@yuca.com` |
| Humedad crítica | crítico | 30 – 90 | `agronomo@yuca.com`, `gerencia@yuca.com` |

Una lectura de **85 %** dispara solo "fuera de óptimo" (correo al agrónomo). Una de **95 %** dispara los dos eventos.

---

## Situación actual

| Pieza | Estado |
|-------|--------|
| `variables` | `nombre`, `unidad`, `decimales`, `descripcion`. Sin rangos ni eventos |
| `lecturas` | `{sensor, variable, fecha, hora_registro, valor}`. Sin estado (el `normal/alerta/critico` fijo se eliminó con `LecturaSensor` el 2026-07-23) |
| Correo | `ApplicationMailer` con `from@example.com`, **sin SMTP configurado** |
| Jobs | `solid_queue` en producción (`config.active_job.queue_adapter`), adaptador `async` en desarrollo |
| Destinatarios | No existe ninguna lista de contactos para avisos |

---

## Decisiones

| Tema | Decisión |
|------|----------|
| Canal | ✅ **Solo correo electrónico.** No hay SMS |
| Alcance del rango | ✅ **General por variable**: aplica igual a todos los cultivos, sensores y fincas. No hay rango por cultivo |
| Quién lo define | ✅ El **usuario desde la pantalla Variables**, sin umbrales fijos en el código. Requiere el permiso `variables:editar`. Los cambios aplican de inmediato a las lecturas nuevas |
| Cantidad | ✅ **Uno o varios eventos por variable**. Una variable sin eventos no genera alertas |
| Destinatarios | ✅ Cada evento tiene su **lista de correos** |
| Contenido de un evento | `nombre`, `severidad` (`alerta` \| `critico`, para el color en la UI y el asunto del correo), `rango_min` / `rango_max` (al menos uno), `notificar_email`, `emails`, intervalo anti-spam, `activo` |
| Disparo | Una lectura dispara **cada evento activo** cuyo rango no cumple (`valor < rango_min` → `bajo`, `valor > rango_max` → `alto`). Puede disparar varios a la vez |
| Anti-spam | Por evento (`intervalo_minutos`, default 60): máximo un correo por **sensor + evento** en ese intervalo. La alerta se registra siempre; solo se omite el envío |
| Estado de la lectura | Se **calcula** contra los eventos vigentes al serializar (no se guarda en `lecturas`): `normal` si no dispara ninguno; si no, la severidad más alta disparada. La alerta sí guarda una copia del rango con el que se disparó |
| Alcance de esta fase | ✅ **Solo pruebas locales.** Los correos no salen a internet: se ven en el navegador con `letter_opener_web` y con los previews de ActionMailer. El SMTP real queda como GAP |
| Proveedor de correo | ActionMailer. Local: `letter_opener_web`. Producción: SMTP por variables de entorno (ver GAPs) |

---

## Tareas — Backend (yuca-backend)

### 1. Migración — tabla `variable_eventos`

```ruby
create_table :variable_eventos do |t|
  t.references :variable, null: false, foreign_key: true
  t.string  :nombre,    null: false
  t.string  :severidad, null: false, default: "alerta"      # "alerta" | "critico"
  t.decimal :rango_min, precision: 8, scale: 2
  t.decimal :rango_max, precision: 8, scale: 2
  t.boolean :notificar_email, null: false, default: true
  t.string  :emails, array: true, null: false, default: []
  t.integer :intervalo_minutos, null: false, default: 60
  t.boolean :activo, null: false, default: true
  t.timestamps
end
add_index :variable_eventos, [ :variable_id, :nombre ], unique: true
```

**Archivo:** `db/migrate/2026XXXXXXXXXX_create_variable_eventos.rb`

---

### 2. Migración — tabla `alertas`

```ruby
create_table :alertas do |t|
  t.references :lectura,         null: false, foreign_key: true
  t.references :variable_evento, null: false, foreign_key: true
  t.references :sensor,   null: false, foreign_key: { to_table: :sensores }
  t.references :variable, null: false, foreign_key: true
  t.references :finca,    null: false, foreign_key: true
  t.string   :tipo,      null: false                        # "bajo" | "alto"
  t.string   :severidad, null: false                        # copia del evento
  t.decimal  :valor,     precision: 8, scale: 2, null: false
  t.decimal  :rango_min, precision: 8, scale: 2             # copia del rango al disparar
  t.decimal  :rango_max, precision: 8, scale: 2
  t.datetime :email_enviado_at
  t.string   :emails_enviados, array: true, default: []     # a quién se envió
  t.boolean  :notificacion_omitida, null: false, default: false   # por intervalo anti-spam
  t.text     :error_envio
  t.timestamps
end
add_index :alertas, [ :sensor_id, :variable_evento_id, :created_at ]
add_index :alertas, [ :finca_id, :created_at ]
add_index :alertas, [ :lectura_id, :variable_evento_id ], unique: true
```

**Archivo:** `db/migrate/2026XXXXXXXXXX_create_alertas.rb`

---

### 3. Modelo `VariableEvento` (nuevo)

- `belongs_to :variable`, `has_many :alertas, dependent: :destroy`; `SEVERIDADES = %w[alerta critico]`; scope `activos`.
- Validaciones:
  - `nombre` obligatorio, único dentro de la variable.
  - Al menos uno de `rango_min` / `rango_max`; `rango_min < rango_max` si vienen ambos.
  - `intervalo_minutos` entero ≥ 1.
  - `notificar_email` → `emails` con **al menos un correo**, cada uno válido (`URI::MailTo::EMAIL_REGEXP`), máximo 10.
- `before_validation`: quita espacios y duplicados y pasa los correos a minúscula.
- `evaluar(valor)` → `"bajo"`, `"alto"` o `nil` (dentro del rango).

**Archivo:** `app/models/variable_evento.rb`

### 4. Modelo `Variable`

- `has_many :eventos, class_name: "VariableEvento", dependent: :destroy`.
- `accepts_nested_attributes_for :eventos, allow_destroy: true` para crear / editar / borrar eventos en el mismo request de la variable.
- `eventos_disparados(valor)` → eventos activos cuyo `evaluar(valor)` no es `nil`.

**Archivo:** `app/models/variable.rb`

---

### 5. Modelo `Alerta` (nuevo)

- `belongs_to :lectura, :variable_evento, :sensor, :variable, :finca`.
- Scope `recientes`; `.ultima_notificada(sensor, evento)` → última alerta con correo enviado, para el intervalo anti-spam.

**Archivo:** `app/models/alerta.rb` (+ `has_many :alertas` en `Lectura`, `Sensor`, `Finca`)

---

### 6. Disparo desde `Lectura`

`after_create_commit` en `Lectura` → `Alertas::EvaluarLectura.call(lectura)`:

1. Para cada evento en `variable.eventos_disparados(valor)`:
   1. Crea la `Alerta` (tipo, severidad y copia del rango del evento).
   2. Si el evento tiene `notificar_email` y **no** hubo una alerta notificada para ese sensor + evento dentro de `intervalo_minutos` → `NotificarAlertaJob.perform_later(alerta.id)`. Si la hubo → `notificacion_omitida: true`.

Al vivir en el modelo, cubre `LecturasController#create` y `Iot::LecturasSyncController` sin cambiarlos. En un sync con muchas lecturas fuera de rango, el intervalo evita mandar un correo por cada una.

**Archivos:** `app/models/lectura.rb`, `app/services/alertas/evaluar_lectura.rb`

---

### 7. Envío — job y mailer

- **`NotificarAlertaJob`** (`app/jobs/notificar_alerta_job.rb`): carga la alerta y su evento, envía `AlertaMailer.fuera_de_rango(alerta).deliver_now` a **todos los correos del evento** (leídos al momento del envío) y guarda `email_enviado_at` y `emails_enviados`. Si falla, guarda el error en `error_envio`; `retry_on` con 3 intentos.
- **`AlertaMailer`** (`app/mailers/alerta_mailer.rb`): `fuera_de_rango(alerta)` con `to: evento.emails`, asunto *"[CRÍTICO] Humedad crítica — Lote Sur, Agrícola El Porvenir"*. Vistas `app/views/alerta_mailer/fuera_de_rango.html.erb` y `.text.erb` y layout propio `app/views/layouts/alerta_mailer.html.erb`. El diseño completo está en la sección **Diseño del correo**.
- **`ApplicationMailer`**: `default from: ENV.fetch("MAIL_FROM", "Yuca Alertas <alertas@yuca.local>")`.
- **Local (esta fase):**
  - Gem `letter_opener_web` (grupo `development`), montada en `config/routes.rb` en `/letter_opener` solo en desarrollo.
  - `config/environments/development.rb`: `delivery_method = :letter_opener_web`, `perform_deliveries = true`, `raise_delivery_errors = true`.
  - Preview de ActionMailer `test/mailers/previews/alerta_mailer_preview.rb` con un caso **crítico** y otro **alerta**, en `/rails/mailers/alerta_mailer`, para iterar el diseño sin crear lecturas.
  - `FRONTEND_URL` (default `http://localhost:5173`) para el botón *Ver lecturas del sensor*.
- **Producción:** fuera de esta fase (ver GAPs). Cuando se active, además del SMTP hay que confirmar que el worker de `solid_queue` corre (`SOLID_QUEUE_IN_PUMA=true` o `bin/jobs`).

---

### 8. API

**Variables** (`VariablesController`): la variable incluye sus eventos; se crean / editan / borran en el mismo `POST` / `PATCH`.

Entrada:

```json
{
  "variable": {
    "nombre": "Humedad", "unidad": "%", "decimales": 1,
    "eventos_attributes": [
      {
        "nombre": "Humedad fuera de óptimo", "severidad": "alerta",
        "rango_min": 40, "rango_max": 80,
        "notificar_email": true, "emails": ["agronomo@yuca.com"],
        "intervalo_minutos": 60, "activo": true
      },
      { "id": "7", "_destroy": true }
    ]
  }
}
```

Salida:

```json
{
  "id": "1", "nombre": "Humedad", "unidad": "%", "decimales": 1,
  "eventos": [
    {
      "id": "6", "nombre": "Humedad fuera de óptimo", "severidad": "alerta",
      "rango": { "min": 40.0, "max": 80.0 },
      "notificaciones": { "email": true, "emails": ["agronomo@yuca.com"], "intervaloMinutos": 60 },
      "activo": true
    }
  ]
}
```

Errores `422` con la ruta del evento:

```json
{ "errors": {
    "eventos[0].emails": ["debe tener al menos un correo si la notificación por correo está activa"],
    "eventos[1].rango_min": ["debe ser menor que el máximo"]
} }
```

**Lecturas** (`LecturasController#serialize_lectura`): agregar `estado` (`"normal"` | `"alerta"` | `"critico"` | `null` si la variable no tiene eventos) y `eventos: [{ id, nombre, severidad, tipo: "bajo" | "alto" }]` disparados. Filtro opcional `?estado=fuera` (dispara al menos un evento).

**Alertas** (nuevo, solo lectura): `GET /api/v1/fincas/:finca_id/alertas`, paginado, filtros `sensor_id`, `variable_id`, `evento_id`, `severidad`, `fecha_desde` / `fecha_hasta`. Permiso: `mediciones:ver`.

```json
{
  "id": "12", "tipo": "alto", "severidad": "critico", "valor": 95.2,
  "rango": { "min": 30.0, "max": 90.0 },
  "evento": { "id": "8", "nombre": "Humedad crítica" },
  "variable": { "id": "1", "nombre": "Humedad", "unidad": "%" },
  "sensor": { "id": "3", "codigo": "SHT-3x-A" }, "cultivo": { "id": "2", "nombre": "Lote Sur" },
  "fecha": "2026-09-28", "horaRegistro": "14:00",
  "envio": {
    "enviadoAt": "2026-09-28T19:00:04Z",
    "emails": ["agronomo@yuca.com", "gerencia@yuca.com"],
    "omitido": false, "error": null
  }
}
```

**Archivos:** `app/controllers/api/v1/variables_controller.rb`, `lecturas_controller.rb`, `alertas_controller.rb` (nuevo), `config/routes.rb`

---

### 9. Seeds

Eventos iniciales en `db/seeds/lecturas_el_porvenir.rb`, con correo a `alertas@yuca.com`:

| Variable | Evento | Severidad | Mín | Máx |
|----------|--------|-----------|-----|-----|
| Humedad (%) | Humedad fuera de óptimo | alerta | 40 | 80 |
| Humedad (%) | Humedad crítica | crítico | 30 | 90 |
| Temperatura (°C) | Temperatura fuera de óptimo | alerta | 10 | 33 |
| Temperatura (°C) | Temperatura crítica | crítico | 5 | 38 |
| Luminosidad (lux) | Luminosidad excesiva | alerta | — | 100000 |

Crear los eventos **después** de generar las 960 lecturas demo, para no disparar cientos de correos al sembrar.

---

### 10. Tests

- `test/models/variable_evento_test.rb`: validaciones de rango, lista de correos obligatoria con `notificar_email`, formato, normalización, duplicados, máximo 10, `evaluar`.
- `test/models/variable_test.rb`: `eventos_attributes` (crear, editar, `_destroy`) y `eventos_disparados` con varios eventos.
- `test/services/alertas/evaluar_lectura_test.rb`: una lectura dispara 0, 1 o 2 eventos; eventos inactivos no disparan; evento sin `notificar_email` crea la alerta sin encolar correo; respeta el intervalo por sensor + evento.
- `test/jobs/notificar_alerta_job_test.rb`: correo a toda la lista (`ActionMailer::Base.deliveries`), guarda `emails_enviados`, registra el error si falla.
- `test/mailers/alerta_mailer_test.rb`: asunto con severidad y contenido.

---

### 11. Documentación

- `docs/api/v1/variables/INTEGRATION.md`: eventos, `eventos_attributes`, errores.
- `docs/api/v1/alertas/INTEGRATION.md` (nuevo).
- Lecturas (`estado`, `eventos`, filtro `estado=fuera`) y variables de entorno de correo.

---

## Diseño del correo

**Prototipo:** [`docs/emails/alerta_fuera_de_rango.html`](./emails/alerta_fuera_de_rango.html). Ábrelo en el navegador: es la referencia visual exacta para `fuera_de_rango.html.erb`.

### Estructura (de arriba a abajo)

| Bloque | Contenido |
|--------|-----------|
| Preheader (oculto) | Resumen que se ve en la bandeja de entrada: *"Humedad 95.2 % en Lote Sur, por encima del máximo permitido (90 %). Sensor SHT-3x-A · 28 sep 2026, 14:00."* |
| Marca | Isotipo verde con 🌱, **Yuca** · *Monitoreo agrícola*, y fecha / hora de la lectura a la derecha |
| Franja de severidad | Barra superior de 6 px con el color de la severidad |
| Encabezado | Etiqueta **CRÍTICO** / **ALERTA**, título *"Humedad crítica en Lote Sur"* y una frase con sensor y finca |
| Valor destacado | Caja con el valor grande (52 px, `95.2 %`) y una píldora *"▲ Por encima del máximo · +5.2 %"* (o *"▼ Por debajo del mínimo · −x"*) |
| Barra de rango | Tres zonas **Bajo / Permitido / Alto**: la zona permitida en verde con `30 % – 90 %`, la zona donde cayó la lectura en el color de la severidad y un marcador `▲ 95.2 %`. Si el evento solo tiene mínimo o solo máximo, se omite la zona que no aplica |
| Detalle | Tabla clave–valor: Finca, Cultivo (o *"Sin cultivo"*), Sensor (código · nombre), Evento, Fecha y hora |
| Botón | **Ver lecturas del sensor →**, enlace a `FRONTEND_URL/dashboard/lecturas?finca=ID&sensor=ID`. Versión VML para Outlook |
| Nota anti-spam | *"No recibirás otro aviso de este evento para este sensor durante los próximos 60 minutos…"* con el `intervalo_minutos` del evento |
| Pie | Por qué recibe el correo (evento y variable), cómo salir de la lista y *"Correo automático, no respondas a este mensaje."* |

### Tokens de diseño

| Token | Valor |
|-------|-------|
| Marca | forest `#2E632B` (botón, isotipo), `#0f2210` / `#1a3a18` (títulos), earth `#564430` / `#8c7354` (texto secundario) |
| Fondo | página `#f4f1ec`, tarjeta `#ffffff` con borde `#e7dfd3` y radio 16 px, cajas suaves `#f8f3ee` |
| Crítico | acento `#B42318`, fondo `#FEF3F2`, borde `#FECDCA`, etiqueta `CRÍTICO` |
| Alerta | acento `#B54708`, fondo `#FFFAEB`, borde `#FEDF89`, etiqueta `ALERTA` |
| Zona permitida | `#a8d3a5` (forest-200) |
| Modo oscuro | página `#0f1a10`, tarjeta `#16241a`, cajas `#1d2e21`, texto `#eef5ee` / `#b7c8b8`; crítico: fondo `#3b1511`, borde `#7a271a`, texto `#fda29b` (alerta: equivalentes en ámbar) |
| Tipografía | `Segoe UI, Helvetica, Arial, sans-serif`; título 24 px / 700, valor 52 px / 800, cuerpo 15 px, detalle 14 px, pie 12 px |

### Reglas técnicas (compatibilidad con clientes de correo)

- Maquetación con **tablas** y **estilos en línea**; ancho 600 px centrado; sin JavaScript, sin fuentes web, sin imágenes externas (el isotipo es un emoji sobre fondo de color, así no depende de que el cliente cargue imágenes).
- **Responsive:** en pantallas < 620 px el contenedor pasa a 100 %, el valor baja a 44 px y la píldora se apila debajo del valor.
- **Modo oscuro:** `color-scheme: light dark` + `@media (prefers-color-scheme: dark)` con clases `.bg-*` / `.text-*` (Apple Mail, iOS, Outlook.com).
- **Outlook:** botón con `v:roundrect` (VML) dentro de comentarios condicionales `<!--[if mso]>`.
- **Accesibilidad:** `lang="es"`, `role="presentation"` en las tablas de layout, contraste AA en textos, la severidad nunca se comunica solo con color (siempre va la etiqueta en texto).
- **Versión texto** (`fuera_de_rango.text.erb`) con la misma información, para clientes sin HTML y para filtros de spam.

### Variables del ERB

`@alerta`, `@evento`, `@variable`, `@lectura`, `@sensor`, `@cultivo`, `@finca`, `@url_lecturas`, y un helper `AlertaMailerHelper` con `severidad_tokens(severidad)` (colores y etiqueta), `valor_con_unidad(valor, variable)` (respeta `decimales`), `desviacion(alerta)` (`+5.2 %` / `−3.0 °C`) y `fecha_hora_larga(lectura)` (*"28 de septiembre de 2026, 14:00"*).

---

## Tareas — Frontend (yuca-frontend)

### 1. Tipos y servicios

- `src/types/variables.types.ts`: `VariableEvento` (`id`, `nombre`, `severidad`, `rango`, `notificaciones`, `activo`) y `eventos: VariableEvento[]` en `Variable`; `VariableEventoFormData` y `eventos` en `VariableFormData`.
- `src/services/variables/variablesService.ts`: enviar `eventos_attributes` (incluye `_destroy` de los eventos quitados).
- `src/types/lecturas.types.ts`: `estado: 'normal' | 'alerta' | 'critico' | null` y `eventos` disparados.
- `src/types/alertas.types.ts` + `src/services/alertas/alertasService.ts` (nuevos).

### 2. `VariablesPage` — eventos de la variable

- Nueva sección **"Eventos"** en el modal de la variable, con botón **"Agregar evento"**. Cada evento es una tarjeta colapsable con:
  - *Nombre* y *Severidad* (Alerta / Crítico, con color).
  - *Mínimo* y *Máximo* (con la unidad de la variable como sufijo).
  - Checkbox *Enviar correo* → **lista de correos** (input + Enter / botón *Agregar*, chips con ✕).
  - *Intervalo mínimo entre correos (minutos)* y switch *Activo*.
  - Botón *Eliminar evento*.
- Componentes nuevos: `src/components/ui/TagListInput.tsx` (valida el formato de cada correo, evita duplicados, máximo 10) y `src/pages/variables/VariableEventoCard.tsx`.
- Validación por evento: nombre, al menos un límite, `min < max`, al menos un correo si *Enviar correo* está activo. Los `422` del backend (`eventos[i].campo`) se muestran en la tarjeta correspondiente.
- Tabla de variables: columna **Eventos** con chips por evento (`Fuera de óptimo 40–80 %`, `Crítica 30–90 %`) coloreados por severidad, y ✉ con la cantidad de correos.

### 3. Lecturas — marcar fuera de rango (`SensorLecturasPanel`)

- Gráfico: una banda (`ReferenceArea`) por evento de la variable, coloreada por severidad (amarillo alerta, rojo crítico); puntos fuera de rango con el color de la severidad más alta.
- Tabla: badge por fila *Normal* / *Alerta* / *Crítico* con tooltip de los eventos disparados.
- Filtro *"Solo fuera de rango"* (`estado=fuera`).

### 4. Alertas

- Dashboard: tarjeta **"Alertas recientes"** (últimas 5 de la finca) y contador de alertas de hoy por severidad (`dashboardStatsService`).
- **Enlace desde el correo:** `LecturasPage` lee `?finca=ID&sensor=ID` de la URL (`useSearchParams`) y abre directamente ese sensor. Hoy la página no lee parámetros.
- Pestaña **"Alertas"** en la página de Lecturas: tabla paginada con evento, severidad, variable, valor vs. rango, sensor / cultivo, fecha y estado del correo (*enviado a N correos*, *omitido por intervalo*, *error*). Filtros por variable, evento y severidad.

---

## Verificación (local)

**Backend** — contra un Postgres local (el `.env` apunta al RDS):
```bash
DATABASE_HOST=localhost bin/rails db:migrate
DATABASE_HOST=localhost bin/rails test
DATABASE_HOST=localhost bin/rails server
```
- **Diseño:** abrir `http://localhost:3000/rails/mailers/alerta_mailer` y revisar los previews *crítico* y *alerta* (HTML y texto), en ancho de escritorio y de móvil.
- **Flujo real:** configurar en Humedad los dos eventos del ejemplo y crear lecturas; los correos aparecen en `http://localhost:3000/letter_opener`:
  - Lectura `85` → 1 alerta ("fuera de óptimo"), 1 correo a la lista del evento.
  - Lectura `95` → 2 alertas, un correo por evento a su lista.
  - Otra lectura `95` del mismo sensor dentro de 60 min → 2 alertas con `notificacion_omitida: true`, sin correo.
  - Sync IoT con 10 lecturas `95` del mismo sensor → 20 alertas, un solo correo por evento.
  - Desactivar un evento → deja de disparar.
- El botón del correo abre `http://localhost:5173/dashboard/lecturas?finca=…&sensor=…` con el sensor seleccionado.
- `GET /api/v1/fincas/:id/alertas` con filtros y `GET .../lecturas?estado=fuera`.

**Frontend**
```bash
npm run lint && npm run build
```
- Crear una variable con dos eventos y sus listas de correos, ver las bandas y los puntos en Lecturas, la alerta en el Dashboard y el estado del correo en la pestaña Alertas.

---

## GAPs (fuera de esta fase)

| # | GAP | Impacto mientras siga abierto | Qué se necesita para cerrarlo |
|---|-----|-------------------------------|-------------------------------|
| 1 | **Remitente y SMTP de producción** | Los correos solo se ven en local (`letter_opener_web`); en producción no salen | Dominio y remitente verificados en AWS SES (ej. `alertas@yuca.com`) u otro SMTP; configurar `MAIL_FROM`, `SMTP_*` y el worker de `solid_queue` |
| 2 | **Evento solo visual** (sin correo) | Se implementa permitiendo `notificar_email: false` (el evento marca la lectura y crea la alerta, sin correo). Si se decide que no se permite, basta una validación | Confirmar si se permite |

Confirmado:
- **Solo correo electrónico**; no hay SMS.
- El rango es **general por variable** (no por cultivo).
- Los eventos los define el **usuario desde la pantalla Variables**; no hay umbrales fijos en el código.
- Cada variable puede tener **uno o varios eventos**, cada uno con su rango y su **lista de correos**.
