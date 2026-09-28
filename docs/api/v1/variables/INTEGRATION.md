# Variables API — Guía de integración

Base URL: `http://localhost:3000` (producción: reemplazar por el dominio real)

Todos los endpoints requieren autenticación. Incluye el token en cada request:

```
Authorization: Bearer <TOKEN>
Content-Type: application/json
```

Para obtener el token consulta [`docs/api/v1/auth/INTEGRATION.md`](../auth/INTEGRATION.md).

`Variable` es un catálogo global, no está anidada bajo ningún recurso.

---

## Índice

1. [Obtener token de prueba](#0-obtener-token-de-prueba)
2. [Listar variables](#1-listar-variables)
3. [Detalle de variable](#2-detalle-de-variable)
4. [Crear variable](#3-crear-variable)
5. [Actualizar variable](#4-actualizar-variable)
6. [Eliminar variable](#5-eliminar-variable)
7. [Eventos de tolerancia](#6-eventos-de-tolerancia)
8. [Manejo de errores](#manejo-de-errores)

---

## 0. Obtener token de prueba

```bash
curl -s -X POST "http://localhost:3000/api/v1/auth/sign_in" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "andres.torres@yuca.com",
      "password": "password123"
    }
  }' | grep -o '"token":"[^"]*"'
```

```bash
export TOKEN="eyJhbGci..."
```

---

## 1. Listar variables

Retorna todas las variables ordenadas alfabéticamente por nombre.

```bash
curl -X GET "http://localhost:3000/api/v1/variables" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**

```json
[
  {
    "id": "1",
    "nombre": "Humedad",
    "unidad": "%",
    "decimales": 1,
    "descripcion": "Porcentaje de humedad relativa del ambiente.",
    "createdAt": "2026-06-24T20:48:49Z",
    "updatedAt": "2026-06-24T20:48:49Z"
  },
  {
    "id": "2",
    "nombre": "Temperatura",
    "unidad": "°C",
    "decimales": 1,
    "descripcion": "Temperatura del ambiente en grados Celsius.",
    "createdAt": "2026-06-24T20:48:49Z",
    "updatedAt": "2026-06-24T20:48:49Z"
  }
]
```

---

## 2. Detalle de variable

```bash
curl -X GET "http://localhost:3000/api/v1/variables/1" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:** objeto `Variable` completo (mismo shape que los elementos del listado).

**Respuesta `404 Not Found`:**

```json
{ "error": "Variable no encontrada" }
```

---

## 3. Crear variable

`descripcion` es opcional. `decimales` acepta valores entre `0` y `10` (default `2`).

```bash
curl -X POST "http://localhost:3000/api/v1/variables" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "variable": {
      "nombre": "Humedad",
      "unidad": "%",
      "decimales": 1,
      "descripcion": "Porcentaje de humedad relativa del ambiente."
    }
  }'
```

**Sin descripción:**

```bash
curl -X POST "http://localhost:3000/api/v1/variables" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "variable": {
      "nombre": "pH",
      "unidad": "pH",
      "decimales": 2
    }
  }'
```

**Respuesta `201 Created`:**

```json
{
  "id": "3",
  "nombre": "pH",
  "unidad": "pH",
  "decimales": 2,
  "descripcion": null,
  "createdAt": "2026-06-24T20:48:49Z",
  "updatedAt": "2026-06-24T20:48:49Z"
}
```

**Respuesta `422 Unprocessable Entity`** (nombre duplicado):

```json
{
  "errors": {
    "nombre": ["ya ha sido tomado"]
  }
}
```

**Respuesta `422 Unprocessable Entity`** (decimales fuera de rango):

```json
{
  "errors": {
    "decimales": ["debe ser menor que o igual a 10"]
  }
}
```

---

## 4. Actualizar variable

Acepta los mismos campos que el POST. Solo se actualizan los campos enviados.

```bash
curl -X PATCH "http://localhost:3000/api/v1/variables/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "variable": {
      "decimales": 2,
      "descripcion": "Humedad relativa con mayor precisión."
    }
  }'
```

**Respuesta `200 OK`:** objeto `Variable` con los datos actualizados.

---

## 5. Eliminar variable

```bash
curl -X DELETE "http://localhost:3000/api/v1/variables/1" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `204 No Content`:** sin body.

---

## 6. Eventos de tolerancia

Cada variable puede tener **uno o varios eventos**. Un evento define un rango permitido (`rango_min` y/o `rango_max`) y la lista de correos a la que se avisa cuando una lectura sale de él. El rango es **general por variable**: aplica a todos los sensores, cultivos y fincas.

Los eventos se crean, editan y borran en el mismo `POST` / `PATCH` de la variable, con `eventos_attributes`:

| Campo | Tipo | Notas |
|-------|------|-------|
| `id` | string | Solo para editar o borrar un evento existente |
| `nombre` | string | Obligatorio, único dentro de la variable |
| `severidad` | `"alerta"` \| `"critico"` | Default `"alerta"` |
| `rango_min` / `rango_max` | número \| `null` | Al menos uno; `rango_min < rango_max` |
| `notificar_email` | boolean | Default `true` |
| `emails` | string[] | Obligatoria (≥ 1) si `notificar_email`; máx. 10; se normaliza a minúsculas sin duplicados |
| `intervalo_minutos` | entero ≥ 1 | Default 60. Máximo un correo por sensor + evento en ese intervalo |
| `activo` | boolean | Default `true`. Un evento inactivo no marca lecturas ni envía correos |
| `_destroy` | boolean | `true` para borrar el evento (junto con `id`) |

```bash
curl -X PATCH "http://localhost:3000/api/v1/variables/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "variable": {
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
  }'
```

**Respuesta `200 OK`:** la variable con su lista `eventos`:

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

**Respuesta `422`:** los errores de eventos llevan el índice del evento dentro de la colección de la variable (primero los existentes en el orden en que se listan, luego los nuevos):

```json
{
  "errors": {
    "eventos[1].emails": ["debe tener al menos un correo si la notificación por correo está activa"],
    "eventos[2].rango_min": ["debe ser menor que el máximo"],
    "eventos[2].emails": ["correo inválido: mal@"]
  }
}
```

### Qué pasa cuando llega una lectura

1. Para cada evento **activo** cuyo rango no cumple (`valor < rango_min` → `bajo`, `valor > rango_max` → `alto`) se crea una **alerta** (ver [`alertas/INTEGRATION.md`](../alertas/INTEGRATION.md)).
2. Si el evento tiene `notificar_email` y no hubo otro correo para ese sensor + evento dentro de `intervalo_minutos`, se encola el correo a su lista. Si lo hubo, la alerta queda con `motivoOmision: "intervalo"`.
3. Aplica igual a lecturas manuales y a las que llegan por el sync IoT.

Las lecturas (`GET /fincas/:id/sensores/:id/lecturas`) incluyen:
- `estado`: `"normal"`, `"alerta"` o `"critico"` (la severidad más alta disparada), o `null` si la variable no tiene eventos activos.
- `eventos`: los eventos disparados, `[{ id, nombre, severidad, tipo: "bajo" | "alto" }]`.
- `variable.rangos`: los rangos activos de la variable, para dibujar el gráfico.
- Filtro `?estado=fuera`: solo lecturas que incumplen al menos un evento.

---

## Manejo de errores

| Código | Cuándo ocurre | Body |
|--------|--------------|------|
| `401 Unauthorized` | Token ausente, expirado o revocado | `{ "error": "You need to sign in..." }` |
| `404 Not Found` | Variable no existe | `{ "error": "Variable no encontrada" }` |
| `422 Unprocessable Entity` | Falla de validación en create/update | `{ "errors": { "campo": ["mensaje"] } }` |
| `400 Bad Request` | Parámetro raíz faltante (`variable`) | `{ "error": "param is missing..." }` |

---

## Notas para el frontend

| Tema | Detalle |
|------|---------|
| **Unicidad** | `nombre` es único sin importar mayúsculas/minúsculas (`Humedad` y `humedad` se consideran iguales). |
| **decimales** | Indica cuántos decimales soporta la variable al registrar un valor (ej. `1` → `23.4`, `0` → `23`). Rango válido: `0`–`10`. Default: `2`. |
| **Catálogo global** | Las variables son compartidas entre todos los usuarios, no están aisladas por usuario. |
