# Cultivos API — Guía de integración

Base URL: `http://localhost:3000` (producción: reemplazar por el dominio real)

Todos los endpoints requieren autenticación. Incluye el token en cada request:

```
Authorization: Bearer <TOKEN>
Content-Type: application/json
```

Para obtener el token consulta [`docs/api/v1/auth/INTEGRATION.md`](../auth/INTEGRATION.md).

Los cultivos son siempre recursos anidados bajo una finca. Reemplaza `{FINCA_ID}` por el `id` de la finca deseada.

---

## Índice

1. [Obtener token de prueba](#0-obtener-token-de-prueba)
2. [Listar cultivos](#1-listar-cultivos)
3. [Detalle de cultivo](#2-detalle-de-cultivo)
4. [Crear cultivo](#3-crear-cultivo)
5. [Actualizar cultivo](#4-actualizar-cultivo)
6. [Eliminar cultivo](#5-eliminar-cultivo)
7. [Manejo de errores](#manejo-de-errores)
8. [Notas para el frontend](#notas-para-el-frontend)

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

Guarda el valor en una variable de entorno:

```bash
export TOKEN="eyJhbGci..."
export FINCA_ID="1"
```

---

## 1. Listar cultivos

Retorna todos los cultivos de una finca, ordenados del más reciente al más antiguo.

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**

```json
[
  {
    "id": "1",
    "nombre": "Yuca ICA Costeña",
    "descripcion": "Variedad resistente a sequía, ciclo de 10 meses.",
    "puntosUbicacion": [
      { "lat": 4.3372, "lng": -74.3641 },
      { "lat": 4.3380, "lng": -74.3650 },
      { "lat": 4.3365, "lng": -74.3655 },
      { "lat": 4.3358, "lng": -74.3645 }
    ],
    "fincaId": "1",
    "createdAt": "2026-06-24T20:36:13Z",
    "updatedAt": "2026-06-24T20:36:13Z"
  }
]
```

---

## 2. Detalle de cultivo

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos/1" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:** objeto `Cultivo` completo (mismo shape que los elementos del listado).

**Respuesta `404 Not Found`:**

```json
{ "error": "Cultivo no encontrado" }
```

---

## 3. Crear cultivo

`puntosUbicacion` es opcional. Si se envía, acepta entre 1 y 4 puntos con `lat` y `lng` numéricos.

**Con puntos de ubicación:**

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cultivo": {
      "nombre": "Yuca ICA Costeña",
      "descripcion": "Variedad resistente a sequía, ciclo de 10 meses.",
      "puntos_ubicacion": [
        { "lat": 4.3372, "lng": -74.3641 },
        { "lat": 4.3380, "lng": -74.3650 },
        { "lat": 4.3365, "lng": -74.3655 },
        { "lat": 4.3358, "lng": -74.3645 }
      ]
    }
  }'
```

**Sin puntos de ubicación:**

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cultivo": {
      "nombre": "Plátano Hartón",
      "descripcion": "Cultivo intercalado con yuca en zona de ladera."
    }
  }'
```

**Respuesta `201 Created`:**

```json
{
  "id": "2",
  "nombre": "Yuca ICA Costeña",
  "descripcion": "Variedad resistente a sequía, ciclo de 10 meses.",
  "puntosUbicacion": [
    { "lat": 4.3372, "lng": -74.3641 },
    { "lat": 4.338,  "lng": -74.365  },
    { "lat": 4.3365, "lng": -74.3655 },
    { "lat": 4.3358, "lng": -74.3645 }
  ],
  "fincaId": "1",
  "createdAt": "2026-06-24T20:36:13Z",
  "updatedAt": "2026-06-24T20:36:13Z"
}
```

**Respuesta `422 Unprocessable Entity`** (más de 4 puntos):

```json
{
  "errors": {
    "puntos_ubicacion": ["no puede tener más de 4 puntos"]
  }
}
```

**Respuesta `422 Unprocessable Entity`** (coordenada inválida):

```json
{
  "errors": {
    "puntos_ubicacion": ["punto 2 debe tener lat y lng numéricos"]
  }
}
```

---

## 4. Actualizar cultivo

Acepta los mismos campos que el POST. Solo se actualizan los campos enviados.

**Cambiar solo el nombre:**

```bash
curl -X PATCH "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cultivo": {
      "nombre": "Yuca Venezolana"
    }
  }'
```

**Reemplazar puntos de ubicación:**

```bash
curl -X PATCH "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cultivo": {
      "puntos_ubicacion": [
        { "lat": 4.3400, "lng": -74.3700 },
        { "lat": 4.3410, "lng": -74.3710 }
      ]
    }
  }'
```

**Limpiar puntos de ubicación:**

```bash
curl -X PATCH "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cultivo": {
      "puntos_ubicacion": []
    }
  }'
```

**Respuesta `200 OK`:** objeto `Cultivo` con los datos actualizados.

---

## 5. Eliminar cultivo

```bash
curl -X DELETE "http://localhost:3000/api/v1/fincas/$FINCA_ID/cultivos/1" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `204 No Content`:** sin body.

**Respuesta `404 Not Found`:**

```json
{ "error": "Cultivo no encontrado" }
```

---

## Manejo de errores

| Código | Cuándo ocurre | Body |
|--------|--------------|------|
| `401 Unauthorized` | Token ausente, expirado o revocado | `{ "error": "You need to sign in..." }` |
| `404 Not Found` | Finca no existe o pertenece a otro usuario | `{ "error": "Finca no encontrada" }` |
| `404 Not Found` | Cultivo no existe o no pertenece a la finca | `{ "error": "Cultivo no encontrado" }` |
| `422 Unprocessable Entity` | Falla de validación en create/update | `{ "errors": { "campo": ["mensaje"] } }` |
| `400 Bad Request` | Parámetro raíz faltante (`cultivo`) | `{ "error": "param is missing..." }` |

---

## Notas para el frontend

| Tema | Detalle |
|------|---------|
| **Puntos de ubicación** | Se envían como `puntos_ubicacion` (snake_case) y se devuelven como `puntosUbicacion` (camelCase). Máximo 4 puntos. |
| **Reemplazo completo** | Al enviar `puntos_ubicacion` en un PATCH, se reemplazan **todos** los puntos existentes. Para eliminarlos enviar `[]`. |
| **Aislamiento por usuario** | El acceso a una finca valida que pertenezca al usuario autenticado. No es posible acceder a cultivos de fincas de otro usuario. |
| **Coordenadas** | `lat` y `lng` se aceptan como número o string numérico y siempre se devuelven como `float`. |
