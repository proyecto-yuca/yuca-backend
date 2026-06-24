# Usuarios — Ejemplos cURL

```bash
export TOKEN="eyJhbGci..."
```

> Todos los endpoints requieren rol `admin`.

---

### Listar usuarios

```bash
curl -X GET "http://localhost:3000/api/v1/usuarios" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**
```json
[
  {
    "id": "1",
    "name": "Andrés Felipe Torres",
    "email": "andres.torres@yuca.com",
    "rol": {
      "id": "1",
      "identificador": "admin",
      "nombre": "Administrador"
    },
    "createdAt": "2026-06-24T21:47:00Z",
    "updatedAt": "2026-06-24T21:47:00Z"
  }
]
```

---

### Detalle de usuario

```bash
curl -X GET "http://localhost:3000/api/v1/usuarios/1" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `404 Not Found`:**
```json
{ "error": "Usuario no encontrado" }
```

---

### Crear usuario

```bash
curl -X POST "http://localhost:3000/api/v1/usuarios" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": {
      "name": "Juan Pérez",
      "email": "juan.perez@yuca.com",
      "password": "password123",
      "password_confirmation": "password123",
      "rol_id": 2
    }
  }'
```

**Respuesta `201 Created`:**
```json
{
  "id": "3",
  "name": "Juan Pérez",
  "email": "juan.perez@yuca.com",
  "rol": {
    "id": "2",
    "identificador": "consultant",
    "nombre": "Consultor"
  },
  "createdAt": "2026-06-24T23:07:46Z",
  "updatedAt": "2026-06-24T23:07:46Z"
}
```

**Respuesta `422 Unprocessable Entity`:**
```json
{
  "errors": {
    "email": ["ya ha sido tomado"],
    "password_confirmation": ["no coincide con Password"]
  }
}
```

---

### Actualizar usuario

Solo enviar los campos a modificar. `password` es opcional.

```bash
curl -X PATCH "http://localhost:3000/api/v1/usuarios/3" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": {
      "name": "Juan Pablo Pérez",
      "rol_id": 3
    }
  }'
```

**Cambiar contraseña:**
```bash
curl -X PATCH "http://localhost:3000/api/v1/usuarios/3" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": {
      "password": "nuevaPassword123",
      "password_confirmation": "nuevaPassword123"
    }
  }'
```

**Respuesta `200 OK`:** objeto `Usuario` actualizado.

---

### Cambiar contraseña

```bash
curl -X PATCH "http://localhost:3000/api/v1/usuarios/3/cambiar_password" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "usuario": {
      "password": "nuevaPassword123",
      "password_confirmation": "nuevaPassword123"
    }
  }'
```

**Respuesta `200 OK`:**
```json
{ "message": "Contraseña actualizada correctamente" }
```

**Respuesta `422`** si las contraseñas no coinciden:
```json
{ "error": "La confirmación de contraseña no coincide" }
```

---

### Activar / desactivar usuario

No requiere body. Alterna entre `estado: true` y `estado: false`. No se puede cambiar el estado del propio usuario autenticado.

```bash
curl -X PATCH "http://localhost:3000/api/v1/usuarios/3/toggle_estado" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**
```json
{
  "id": "3",
  "name": "Juan Pérez",
  "email": "juan.perez@yuca.com",
  "estado": false,
  "rol": { "id": "2", "identificador": "consultant", "nombre": "Consultor" },
  "createdAt": "2026-06-24T23:07:46Z",
  "updatedAt": "2026-06-24T23:10:00Z"
}
```

**Respuesta `422`** al intentar cambiar el propio estado:
```json
{ "error": "No puedes cambiar el estado de tu propio usuario" }
```

---

### Eliminar usuario

No es posible eliminar el propio usuario autenticado.

```bash
curl -X DELETE "http://localhost:3000/api/v1/usuarios/3" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `204 No Content`:** sin body.

**Respuesta `422`** al intentar eliminarse a sí mismo:
```json
{ "error": "No puedes eliminar tu propio usuario" }
```

---

## Roles disponibles para `rol_id`

Obtén los roles dinámicamente para poblar el dropdown:

```bash
curl -X GET "http://localhost:3000/api/v1/roles" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**
```json
[
  { "id": "1", "identificador": "admin",      "nombre": "Administrador", "descripcion": "Acceso total al sistema", "sistema": true, "usuarios": 2 },
  { "id": "2", "identificador": "consultant", "nombre": "Consultor",     "descripcion": "Consultor agrícola",      "sistema": true, "usuarios": 1 },
  { "id": "3", "identificador": "owner",      "nombre": "Propietario",   "descripcion": "Dueño de fincas",         "sistema": true, "usuarios": 0 },
  { "id": "4", "identificador": "user",       "nombre": "Usuario",       "descripcion": "Usuario estándar",        "sistema": true, "usuarios": 0 }
]
```
