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
7. [Manejo de errores](#manejo-de-errores)

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
