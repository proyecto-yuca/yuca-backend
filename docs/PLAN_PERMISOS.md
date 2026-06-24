# Plan: Validación de permisos por módulo

## Objetivo

Proteger cada endpoint según los permisos del rol del usuario autenticado, y exponer esos permisos al frontend para que pueda mostrar u ocultar opciones sin necesidad de requests adicionales.

---

## Tareas

### 1. Seed — módulo `permisos` (solo admin)

- Agregar `{ identificador: "permisos", nombre: "Permisos", orden: 7 }` al seed de módulos.
- Admin: `VCED` (acceso total).
- Consultant, Owner, User: sin acceso (`----`).

**Archivo:** `db/seeds/permisos.rb`

---

### 2. Concern `PermissionGuard`

Crear `app/controllers/concerns/permission_guard.rb` con el método:

```ruby
def require_permiso(modulo_id, operacion)
```

Lógica:
- Si el usuario no tiene rol → `403`.
- Si el rol es `admin` → pasa directo (acceso total, sin consulta extra).
- Busca el `Permiso` del rol para ese módulo y verifica la operación (`ver`, `crear`, `editar`, `eliminar`).
- Si no tiene permiso → `403 Forbidden` con mensaje descriptivo.
- Cachea los permisos del request en `@_permisos_cache` para no repetir queries.

Incluirlo en `BaseController`.

**Archivo:** `app/controllers/concerns/permission_guard.rb`

---

### 3. Proteger cada controller

Agregar `before_action` en cada controller con el módulo correspondiente:

| Controller | Módulo | Ver | Crear | Editar | Eliminar |
|-----------|--------|-----|-------|--------|----------|
| `FincasController` | `fincas` | `index, show` | `create` | `update, estado` | — |
| `CultivosController` | `cultivos` | `index, show` | `create` | `update` | `destroy` |
| `SensoresController` | `sensores` | `index, show` | `create` | `update, toggle` | `destroy` |
| `VariablesController` | `variables` | `index, show` | `create` | `update` | `destroy` |
| `LecturasSensorController` | `mediciones` | `index, recientes` | `create` | — | — |
| `RolesController` | `permisos` | `index, show` | `create` | `update` | `destroy` |
| `PermisosController` | `permisos` | `index` | — | `update` | — |

**Archivos:** cada controller bajo `app/controllers/api/v1/`

---

### 4. Endpoint de permisos del usuario autenticado

```
GET /api/v1/user/permisos
```

Devuelve el rol y la matriz completa de permisos del usuario logueado.

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

**Respuesta `403`** si el usuario no tiene rol asignado:
```json
{ "error": "Usuario sin rol asignado" }
```

**Archivo:** `app/controllers/api/v1/users_controller.rb` + ruta en `config/routes.rb`

---

### 5. Incluir permisos en el login

Modificar `SessionsController#create` para incluir el bloque `permisos` en la respuesta del sign_in. El frontend recibe el token y los permisos en un solo request.

**Respuesta sign_in `200 OK`:**

```json
{
  "token": "eyJhbGci...",
  "user": {
    "id": "1",
    "name": "Andrés Torres",
    "email": "andres.torres@yuca.com",
    "rol": { "id": "1", "identificador": "admin", "nombre": "Administrador" }
  },
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

**Archivo:** `app/controllers/api/v1/auth/sessions_controller.rb`

---

## Orden de implementación

1. `db/seeds/permisos.rb` — agregar módulo `permisos`
2. `app/controllers/concerns/permission_guard.rb` — concern
3. `app/controllers/api/v1/base_controller.rb` — incluir concern
4. Cada controller — agregar `before_action`
5. `app/controllers/api/v1/users_controller.rb` — action `permisos`
6. `config/routes.rb` — ruta `GET /api/v1/user/permisos`
7. `app/controllers/api/v1/auth/sessions_controller.rb` — permisos en login
8. Correr seed

---

## Respuesta de error estándar para permisos

```json
{
  "error": "No tienes permiso para realizar esta acción",
  "modulo": "fincas",
  "operacion": "eliminar"
}
```

HTTP status: `403 Forbidden`
