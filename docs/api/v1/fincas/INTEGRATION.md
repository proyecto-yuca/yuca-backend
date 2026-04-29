# Fincas & Sensores API — Guía de integración

Base URL: `http://localhost:3000` (producción: reemplazar por el dominio real)

Todos los endpoints requieren autenticación. Incluye el token en cada request:

```
Authorization: Bearer <TOKEN>
Content-Type: application/json
```

Para obtener el token consulta [`docs/api/v1/auth/INTEGRATION.md`](../auth/INTEGRATION.md).

---

## Índice

1. [Obtener token de prueba](#0-obtener-token-de-prueba)
2. [Módulo Fincas](#módulo-fincas)
   - [Listar fincas](#1-listar-fincas)
   - [Crear finca](#2-crear-finca)
   - [Detalle de finca](#3-detalle-de-finca)
   - [Actualizar finca](#4-actualizar-finca)
   - [Cambiar estado](#5-cambiar-estado-activoinactivo)
3. [Módulo Sensores](#módulo-sensores)
   - [Listar lecturas](#6-listar-lecturas-con-filtros)
   - [Lecturas del día](#7-lecturas-del-día-recientes)
   - [Registrar lectura](#8-registrar-nueva-lectura)
4. [Manejo de errores](#manejo-de-errores)

---

## 0. Obtener token de prueba

Usa una de las cuentas seed para obtener el JWT antes de probar los demás endpoints:

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

Guarda el valor en una variable de entorno para los siguientes ejemplos:

```bash
export TOKEN="eyJhbGci..."
```

---

## Módulo Fincas

### 1. Listar fincas

```bash
curl -X GET "http://localhost:3000/api/v1/fincas" \
  -H "Authorization: Bearer $TOKEN"
```

**Con paginación:**

```bash
curl -X GET "http://localhost:3000/api/v1/fincas?page=1&page_size=6" \
  -H "Authorization: Bearer $TOKEN"
```

**Con búsqueda full-text** (nombre, municipio, departamento o dueño):

```bash
curl -X GET "http://localhost:3000/api/v1/fincas?search=Fusagasug%C3%A1" \
  -H "Authorization: Bearer $TOKEN"
```

**Filtrar por estado** (`activo` | `inactivo` | `todos`):

```bash
curl -X GET "http://localhost:3000/api/v1/fincas?estado=activo" \
  -H "Authorization: Bearer $TOKEN"
```

**Combinando parámetros:**

```bash
curl -X GET "http://localhost:3000/api/v1/fincas?search=Carlos&estado=activo&page=1&page_size=3" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**

```json
{
  "data": [
    {
      "id": "1",
      "nombre": "Finca El Paraíso",
      "descripcion": "Terreno con buena irrigación natural.",
      "area": 12.5,
      "ubicacion": {
        "departamento": "Cundinamarca",
        "municipio": "Fusagasugá",
        "vereda": "El Jordán",
        "coordenadas": "4.3372° N, 74.3641° W",
        "direccion": "Vereda El Jordán, km 3 vía Silvania"
      },
      "dueno": {
        "nombre": "Carlos Alberto Ramírez",
        "tipoDocumento": "CC",
        "numeroDocumento": "79456123",
        "email": "carlos.ramirez@email.com",
        "telefono": "3001234567",
        "direccion": "Calle 12 #45-23, Fusagasugá"
      },
      "estado": "activo",
      "fechaRegistro": "2024-03-15"
    }
  ],
  "total": 6,
  "page": 1,
  "pageSize": 6,
  "totalPages": 1
}
```

---

### 2. Crear finca

```bash
curl -X POST "http://localhost:3000/api/v1/fincas" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "finca": {
      "nombre": "Finca Nueva Esperanza",
      "descripcion": "Cultivos de yuca y maíz en zona templada.",
      "area": 18.5,
      "ubicacion": {
        "departamento": "Santander",
        "municipio": "Bucaramanga",
        "vereda": "La Cumbre",
        "coordenadas": "7.1193° N, 73.1227° W",
        "direccion": "Vereda La Cumbre, km 6 vía Floridablanca"
      },
      "dueno": {
        "nombre": "Adriana Milena Castro",
        "tipoDocumento": "CC",
        "numeroDocumento": "63459871",
        "email": "adriana.castro@email.com",
        "telefono": "3106789012",
        "direccion": "Calle 45 #32-10, Bucaramanga"
      }
    }
  }'
```

**Respuesta `201 Created`:**

```json
{
  "id": "9",
  "nombre": "Finca Nueva Esperanza",
  "descripcion": "Cultivos de yuca y maíz en zona templada.",
  "area": 18.5,
  "ubicacion": {
    "departamento": "Santander",
    "municipio": "Bucaramanga",
    "vereda": "La Cumbre",
    "coordenadas": "7.1193° N, 73.1227° W",
    "direccion": "Vereda La Cumbre, km 6 vía Floridablanca"
  },
  "dueno": {
    "nombre": "Adriana Milena Castro",
    "tipoDocumento": "CC",
    "numeroDocumento": "63459871",
    "email": "adriana.castro@email.com",
    "telefono": "3106789012",
    "direccion": "Calle 45 #32-10, Bucaramanga"
  },
  "estado": "activo",
  "fechaRegistro": "2026-04-29"
}
```

**Respuesta `422 Unprocessable Entity`** (campos requeridos faltantes):

```json
{
  "errors": {
    "nombre": ["no puede estar en blanco"],
    "area": ["debe ser mayor que 0"],
    "dueno_email": ["no tiene un formato válido"]
  }
}
```

---

### 3. Detalle de finca

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/1" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:** objeto `Finca` completo (mismo shape que los elementos del listado).

**Respuesta `404 Not Found`:**

```json
{ "error": "Finca no encontrada" }
```

---

### 4. Actualizar finca

Acepta los mismos campos que el POST. Solo se actualizan los campos enviados.
`estado` y `fechaRegistro` no se modifican por este endpoint.

```bash
curl -X PATCH "http://localhost:3000/api/v1/fincas/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "finca": {
      "nombre": "Finca El Paraíso — Actualizada",
      "area": 14.0,
      "ubicacion": {
        "departamento": "Cundinamarca",
        "municipio": "Fusagasugá",
        "vereda": "El Jordán",
        "coordenadas": "4.3372° N, 74.3641° W",
        "direccion": "Vereda El Jordán, km 3 vía Silvania"
      },
      "dueno": {
        "nombre": "Carlos Alberto Ramírez",
        "tipoDocumento": "CC",
        "numeroDocumento": "79456123",
        "email": "carlos.ramirez@email.com",
        "telefono": "3001234567",
        "direccion": "Calle 12 #45-23, Fusagasugá"
      }
    }
  }'
```

**Respuesta `200 OK`:** objeto `Finca` con los datos actualizados.

---

### 5. Cambiar estado (activo/inactivo)

No requiere body. Alterna el estado entre `activo` e `inactivo`.

```bash
curl -X PATCH "http://localhost:3000/api/v1/fincas/1/estado" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**

```json
{
  "id": "1",
  "nombre": "Finca El Paraíso",
  "estado": "inactivo",
  "fechaRegistro": "2024-03-15",
  "..."  : "..."
}
```

Llamarlo nuevamente vuelve el estado a `activo`.

---

## Módulo Sensores

Reemplaza `{FINCA_ID}` por el `id` de la finca deseada.

### 6. Listar lecturas con filtros

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/{FINCA_ID}/lecturas" \
  -H "Authorization: Bearer $TOKEN"
```

**Con paginación:**

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/1/lecturas?page=1&page_size=10" \
  -H "Authorization: Bearer $TOKEN"
```

**Filtrar por rango de fechas:**

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/1/lecturas?fecha_desde=2026-04-01&fecha_hasta=2026-04-29" \
  -H "Authorization: Bearer $TOKEN"
```

**Filtrar por estado del sensor** (`normal` | `alerta` | `critico` | `todos`):

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/1/lecturas?estado=alerta" \
  -H "Authorization: Bearer $TOKEN"
```

**Combinando filtros:**

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/1/lecturas?fecha_desde=2026-04-20&fecha_hasta=2026-04-29&estado=normal&page=1&page_size=5" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**

```json
{
  "data": [
    {
      "id": "1",
      "fincaId": "1",
      "fecha": "2026-04-29",
      "horaRegistro": "23:00",
      "sensorId": "SHT-3x-A",
      "humedad": 67.4,
      "temperatura": 22.1,
      "estado": "normal"
    }
  ],
  "total": 120,
  "page": 1,
  "pageSize": 10,
  "totalPages": 12,
  "resumen": {
    "totalLecturas": 120,
    "humedadPromedio": 68.2,
    "temperaturaPromedio": 22.5,
    "humedadMin": 31.0,
    "humedadMax": 97.4,
    "temperaturaMin": 9.8,
    "temperaturaMax": 38.6,
    "alertas": 10,
    "criticos": 0,
    "ultimaLectura": "2026-04-29 23:00"
  }
}
```

---

### 7. Lecturas del día (recientes)

Retorna únicamente las lecturas del día actual. Útil para auto-refresh en el frontend.

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/1/lecturas/recientes" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**

```json
[
  {
    "id": "481",
    "fincaId": "1",
    "fecha": "2026-04-29",
    "horaRegistro": "23:00",
    "sensorId": "SHT-3x-A",
    "humedad": 65.3,
    "temperatura": 21.8,
    "estado": "normal"
  },
  {
    "id": "480",
    "fincaId": "1",
    "fecha": "2026-04-29",
    "horaRegistro": "18:00",
    "sensorId": "SHT-3x-A",
    "humedad": 71.0,
    "temperatura": 24.5,
    "estado": "normal"
  }
]
```

---

### 8. Registrar nueva lectura

El campo `estado` **no** se envía — el servidor lo calcula automáticamente según los umbrales de humedad y temperatura.

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/1/lecturas" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "lectura": {
      "sensorId": "SHT-3x-A",
      "fecha": "2026-04-29",
      "horaRegistro": "11:00",
      "humedad": 78.5,
      "temperatura": 24.3
    }
  }'
```

**Lectura que genera alerta** (humedad < 40):

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/1/lecturas" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "lectura": {
      "sensorId": "DHT-22",
      "fecha": "2026-04-29",
      "horaRegistro": "14:00",
      "humedad": 35.0,
      "temperatura": 29.0
    }
  }'
```

**Lectura crítica** (humedad < 30 o temperatura > 38):

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/1/lecturas" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "lectura": {
      "sensorId": "BME280",
      "fecha": "2026-04-29",
      "horaRegistro": "16:00",
      "humedad": 25.0,
      "temperatura": 39.5
    }
  }'
```

**Respuesta `201 Created`:**

```json
{
  "id": "961",
  "fincaId": "1",
  "fecha": "2026-04-29",
  "horaRegistro": "11:00",
  "sensorId": "SHT-3x-A",
  "humedad": 78.5,
  "temperatura": 24.3,
  "estado": "normal"
}
```

**Respuesta `422 Unprocessable Entity`** (duplicado de fecha + hora en la misma finca):

```json
{
  "errors": {
    "hora_registro": ["ya ha sido tomado"]
  }
}
```

---

## Manejo de errores

| Código | Cuándo ocurre | Body |
|--------|--------------|------|
| `401 Unauthorized` | Token ausente, expirado o revocado | `{ "error": "You need to sign in..." }` |
| `404 Not Found` | Finca no existe o pertenece a otro usuario | `{ "error": "Finca no encontrada" }` |
| `422 Unprocessable Entity` | Falla de validación en create/update | `{ "errors": { "campo": ["mensaje"] } }` |
| `400 Bad Request` | Parámetro raíz faltante (`finca` o `lectura`) | `{ "error": "param is missing..." }` |

---

## Lógica de estados del sensor

El estado se calcula automáticamente en el servidor al guardar cada lectura:

| Estado | Condición |
|--------|-----------|
| `critico` | Humedad < 30% o > 90%, **o** Temperatura < 5°C o > 38°C |
| `alerta` | Humedad < 40% o > 80%, **o** Temperatura < 10°C o > 33°C |
| `normal` | Fuera de los rangos anteriores |

---

## Notas para el frontend

| Tema | Detalle |
|------|---------|
| **camelCase vs snake_case** | El API acepta y devuelve claves en camelCase (`sensorId`, `fechaRegistro`, `tipoDocumento`). |
| **Aislamiento por usuario** | Todas las consultas se filtran por `current_user`. No es posible acceder a fincas de otro usuario aunque se conozca el `id`. |
| **Resumen histórico** | El campo `resumen` en `/lecturas` siempre refleja el **total histórico** de la finca, independientemente de los filtros de fecha/estado aplicados al listado. |
| **Unicidad de lecturas** | No se pueden registrar dos lecturas con la misma `fecha` + `horaRegistro` para la misma finca. |
| **Paginación** | Default: `page=1`, `page_size=6` (fincas) y `page_size=10` (lecturas). Máximo `page_size=100`. |
