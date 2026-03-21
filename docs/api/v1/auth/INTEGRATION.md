# Auth API — Guía de integración

Base URL: `http://localhost:3000` (producción: reemplazar por el dominio real)

El token JWT que recibes en login/registro debe enviarse en el header `Authorization: Bearer <token>` en cada request autenticado. Expira en **30 días**.

---

## 1. Registro

```bash
curl -X POST "http://localhost:3000/api/v1/auth" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "frontend.demo@example.com",
      "password": "Password123!",
      "password_confirmation": "Password123!"
    }
  }'
```

**Respuesta `201 Created`**

```json
{
  "user": {
    "id": 3,
    "email": "frontend.demo@example.com",
    "created_at": "2026-03-21T17:44:06.741Z",
    "updated_at": "2026-03-21T17:44:06.741Z"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzc0MTE1MDQ2LCJleHAiOjE3NzY3MDcwNDYsImp0aSI6ImFjZjc0ZmJlLWNjMmEtNDkzZC05ZDg4LTRmOTIzYzA4MDg2NCJ9.mkQfStdshZEHxaGdMzf5abojF-F9qLaQyPysOKAiQIM"
}
```

**Errores posibles `422 Unprocessable Entity`**

```json
{
  "errors": ["Email has already been taken", "Password is too short (minimum is 6 characters)"]
}
```

---

## 2. Login

```bash
curl -X POST "http://localhost:3000/api/v1/auth/sign_in" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "frontend.demo@example.com",
      "password": "Password123!"
    }
  }'
```

**Respuesta `200 OK`**

```json
{
  "user": {
    "id": 3,
    "email": "frontend.demo@example.com",
    "created_at": "2026-03-21T17:44:06.741Z",
    "updated_at": "2026-03-21T17:44:06.741Z"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzc0MTE1MDQ2LCJleHAiOjE3NzY3MDcwNDYsImp0aSI6IjMwZTE1YTc5LWJmMGEtNDRhMS1iM2ZlLWI4M2VjMzBhOGM1ZiJ9.m7EId3SHcUR4Kc6D5qvCxiHM_MYxV-wHJ0IJCyymxPY"
}
```

**Errores posibles `401 Unauthorized`**

```json
{
  "error": "Invalid Email or password."
}
```

---

## 3. Ver perfil

Requiere token en el header.

```bash
curl -X GET "http://localhost:3000/api/v1/user" \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta `200 OK`**

```json
{
  "user": {
    "id": 3,
    "email": "frontend.demo@example.com",
    "created_at": "2026-03-21T17:44:06.741Z",
    "updated_at": "2026-03-21T17:44:06.741Z"
  }
}
```

**Sin token / token inválido `401 Unauthorized`**

```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

---

## 4. Actualizar perfil

Requiere token. Para cambiar email o password se debe incluir `current_password`.

```bash
curl -X PATCH "http://localhost:3000/api/v1/user" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "user": {
      "email": "nuevo@example.com",
      "current_password": "Password123!"
    }
  }'
```

Para cambiar la contraseña:

```bash
curl -X PATCH "http://localhost:3000/api/v1/user" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{
    "user": {
      "password": "NuevaClave456!",
      "password_confirmation": "NuevaClave456!",
      "current_password": "Password123!"
    }
  }'
```

**Respuesta `200 OK`**

```json
{
  "user": {
    "id": 3,
    "email": "nuevo@example.com",
    "created_at": "2026-03-21T17:44:06.741Z",
    "updated_at": "2026-03-21T17:44:07.002Z"
  }
}
```

---

## 5. Olvidé mi contraseña

No requiere token. Envía el email con instrucciones (aunque el email no exista, devuelve el mismo mensaje por seguridad).

```bash
curl -X POST "http://localhost:3000/api/v1/auth/password" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "frontend.demo@example.com"
    }
  }'
```

**Respuesta `200 OK`**

```json
{
  "message": "Reset password instructions sent if the email exists."
}
```

### Resetear la contraseña con el token del email

El token llega en el link del email como parámetro `reset_password_token`.

```bash
curl -X PUT "http://localhost:3000/api/v1/auth/password" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "reset_password_token": "<TOKEN_DEL_EMAIL>",
      "password": "NuevaClave456!",
      "password_confirmation": "NuevaClave456!"
    }
  }'
```

**Respuesta `200 OK`**

```json
{
  "message": "Password updated successfully."
}
```

---

## 6. Logout

Requiere token. Lo invalida en el servidor (denylist) — el mismo token no podrá usarse de nuevo.

```bash
curl -X DELETE "http://localhost:3000/api/v1/auth/sign_out" \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta `200 OK`**

```json
{
  "message": "Signed out successfully."
}
```

**Sin token `401 Unauthorized`**

```json
{
  "message": "No active session."
}
```

---

## Notas para el frontend

| Tema | Detalle |
|------|---------|
| **Dónde guardar el token** | `localStorage` o `sessionStorage`. Para apps móviles, `SecureStore`. |
| **Cómo enviarlo** | Header `Authorization: Bearer <token>` en cada request autenticado. |
| **Expiración** | 30 días. Si recibes `401`, redirigir al login. |
| **Logout** | Al cerrar sesión, llamar al endpoint Y borrar el token del storage local. |
| **Token revocado** | Si el token fue usado en logout, el servidor responde `401` con `revoked token`. |
