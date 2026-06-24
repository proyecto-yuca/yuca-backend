# Permisos — Ejemplos cURL

```bash
export TOKEN="eyJhbGci..."
```

> Todos los endpoints de roles y permisos requieren rol `admin`. Cualquier otro rol recibe `403 Forbidden`.

---

## Permisos del usuario autenticado

### Ver mis permisos

Útil al iniciar sesión para que el frontend sepa qué mostrar u ocultar.

```bash
curl -X GET "http://localhost:3000/api/v1/user/permisos" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**
```json
{
  "rol": {
    "id": "3",
    "identificador": "owner",
    "nombre": "Propietario"
  },
  "permisos": {
    "inicio":     { "ver": false, "crear": false, "editar": false, "eliminar": false },
    "fincas":     { "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
    "cultivos":   { "ver": false, "crear": false, "editar": false, "eliminar": false },
    "sensores":   { "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
    "variables":  { "ver": false, "crear": false, "editar": false, "eliminar": false },
    "mediciones": { "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
    "permisos":   { "ver": false, "crear": false, "editar": false, "eliminar": false }
  }
}
```

**Respuesta `403`** si el usuario no tiene rol:
```json
{ "error": "Usuario sin rol asignado" }
```

---

## Login — permisos incluidos en la respuesta

El sign_in devuelve los permisos directamente. No se necesita un request extra.

```bash
curl -X POST "http://localhost:3000/api/v1/auth/sign_in" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "andres.torres@yuca.com",
      "password": "password123"
    }
  }'
```

**Respuesta `200 OK`:**
```json
{
  "user": {
    "id": 1,
    "name": "Andrés Felipe Torres",
    "email": "andres.torres@yuca.com",
    "rol": {
      "id": 1,
      "identificador": "admin",
      "nombre": "Administrador",
      "sistema": true
    },
    "created_at": "2026-06-24T21:47:00.242Z",
    "updated_at": "2026-06-24T21:47:00.242Z"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "permisos": {
    "inicio":     { "ver": true, "crear": true, "editar": true, "eliminar": true },
    "fincas":     { "ver": true, "crear": true, "editar": true, "eliminar": true },
    "cultivos":   { "ver": true, "crear": true, "editar": true, "eliminar": true },
    "sensores":   { "ver": true, "crear": true, "editar": true, "eliminar": true },
    "variables":  { "ver": true, "crear": true, "editar": true, "eliminar": true },
    "mediciones": { "ver": true, "crear": true, "editar": true, "eliminar": true },
    "permisos":   { "ver": true, "crear": true, "editar": true, "eliminar": true }
  }
}
```

---

## Módulos

### Listar módulos

```bash
curl -X GET "http://localhost:3000/api/v1/modulos" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**
```json
[
  { "id": "1", "identificador": "inicio",     "nombre": "Inicio",     "orden": 1 },
  { "id": "2", "identificador": "fincas",     "nombre": "Fincas",     "orden": 2 },
  { "id": "3", "identificador": "cultivos",   "nombre": "Cultivos",   "orden": 3 },
  { "id": "4", "identificador": "sensores",   "nombre": "Sensores",   "orden": 4 },
  { "id": "5", "identificador": "variables",  "nombre": "Variables",  "orden": 5 },
  { "id": "6", "identificador": "mediciones", "nombre": "Mediciones", "orden": 6 },
  { "id": "7", "identificador": "permisos",   "nombre": "Permisos",   "orden": 7 }
]
```

---

## Tipos de usuario (Roles)

> Requiere rol `admin`.

### Listar roles

```bash
curl -X GET "http://localhost:3000/api/v1/roles" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**
```json
[
  {
    "id": "1",
    "identificador": "admin",
    "nombre": "Administrador",
    "descripcion": "Acceso total al sistema",
    "sistema": true,
    "usuarios": 2,
    "createdAt": "2026-06-24T21:40:38Z",
    "updatedAt": "2026-06-24T21:40:38Z"
  }
]
```

---

### Detalle de rol

```bash
curl -X GET "http://localhost:3000/api/v1/roles/1" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Crear rol

```bash
curl -X POST "http://localhost:3000/api/v1/roles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "rol": {
      "identificador": "supervisor",
      "nombre": "Supervisor",
      "descripcion": "Supervisa operaciones de campo"
    }
  }'
```

---

### Actualizar rol

```bash
curl -X PATCH "http://localhost:3000/api/v1/roles/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "rol": {
      "nombre": "Administrador General",
      "descripcion": "Acceso total al sistema y configuración"
    }
  }'
```

---

### Eliminar rol

Los roles de sistema (`sistema: true`) no pueden eliminarse.

```bash
curl -X DELETE "http://localhost:3000/api/v1/roles/5" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `422`** al intentar eliminar un rol de sistema:
```json
{ "error": "No se puede eliminar un rol de sistema" }
```

---

## Permisos por módulo

> Requiere rol `admin`.

### Ver permisos de un rol

```bash
curl -X GET "http://localhost:3000/api/v1/roles/1/permisos" \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta `200 OK`:**
```json
[
  { "moduloId": "1", "identificador": "inicio",     "nombre": "Inicio",     "orden": 1, "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
  { "moduloId": "2", "identificador": "fincas",     "nombre": "Fincas",     "orden": 2, "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
  { "moduloId": "3", "identificador": "cultivos",   "nombre": "Cultivos",   "orden": 3, "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
  { "moduloId": "4", "identificador": "sensores",   "nombre": "Sensores",   "orden": 4, "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
  { "moduloId": "5", "identificador": "variables",  "nombre": "Variables",  "orden": 5, "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
  { "moduloId": "6", "identificador": "mediciones", "nombre": "Mediciones", "orden": 6, "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
  { "moduloId": "7", "identificador": "permisos",   "nombre": "Permisos",   "orden": 7, "ver": true,  "crear": true,  "editar": true,  "eliminar": true  }
]
```

---

### Actualizar permisos de un rol (matriz completa)

Enviar todos los módulos a modificar. Los no enviados no se tocan.

```bash
curl -X PUT "http://localhost:3000/api/v1/roles/3/permisos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "permisos": [
      { "modulo_id": "1", "ver": false, "crear": false, "editar": false, "eliminar": false },
      { "modulo_id": "2", "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
      { "modulo_id": "3", "ver": false, "crear": false, "editar": false, "eliminar": false },
      { "modulo_id": "4", "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
      { "modulo_id": "5", "ver": false, "crear": false, "editar": false, "eliminar": false },
      { "modulo_id": "6", "ver": true,  "crear": true,  "editar": true,  "eliminar": true  },
      { "modulo_id": "7", "ver": false, "crear": false, "editar": false, "eliminar": false }
    ]
  }'
```

**Respuesta `200 OK`:**
```json
{ "message": "Permisos actualizados correctamente" }
```

---

## Error de permisos

Cualquier endpoint protegido retorna `403` si el rol no tiene acceso:

```json
{
  "error": "No tienes permiso para realizar esta acción",
  "modulo": "fincas",
  "operacion": "eliminar"
}
```
