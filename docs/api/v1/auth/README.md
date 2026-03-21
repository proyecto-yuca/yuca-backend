# API v1 Auth - cURL examples

Estos ejemplos estan listos para integrar desde frontend.

## Base URL

```bash
BASE_URL="http://localhost:3000"
```

## Flujo recomendado

1. Registro: `POST /api/v1/auth`
2. Login: `POST /api/v1/auth/sign_in`
3. Perfil actual: `GET /api/v1/user`
4. Actualizar usuario: `PATCH /api/v1/user`
5. Olvido de clave: `POST /api/v1/auth/password`
6. Logout: `DELETE /api/v1/auth/sign_out`

## cURL listos para usar

### 1) Registro

```bash
curl -X POST "$BASE_URL/api/v1/auth" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "frontend.demo@example.com",
      "password": "Password123!",
      "password_confirmation": "Password123!"
    }
  }'
```

Respuesta real: `docs/api/v1/auth/responses/register.txt`

### 2) Login

```bash
curl -X POST "$BASE_URL/api/v1/auth/sign_in" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "frontend.demo@example.com",
      "password": "Password123!"
    }
  }'
```

Respuesta real: `docs/api/v1/auth/responses/login.txt`

### 3) Perfil actual

```bash
curl -X GET "$BASE_URL/api/v1/user" \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

Respuesta real: `docs/api/v1/auth/responses/get_user.txt`

### 4) Actualizar usuario

```bash
curl -X PATCH "$BASE_URL/api/v1/user" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -d '{
    "user": {
      "email": "updated.frontend.demo@example.com"
    }
  }'
```

Respuesta real: `docs/api/v1/auth/responses/update_user.txt`

### 5) Olvido de clave

```bash
curl -X POST "$BASE_URL/api/v1/auth/password" \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "frontend.demo@example.com"
    }
  }'
```

Respuesta real: `docs/api/v1/auth/responses/forgot_password.txt`

### 6) Logout

```bash
curl -X DELETE "$BASE_URL/api/v1/auth/sign_out" \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

Respuesta real: `docs/api/v1/auth/responses/logout.txt`

## Regenerar respuestas reales

El archivo `script/generate_auth_examples.rb` ejecuta el flujo completo y vuelve a generar:

- `docs/api/v1/auth/responses/register.txt`
- `docs/api/v1/auth/responses/login.txt`
- `docs/api/v1/auth/responses/get_user.txt`
- `docs/api/v1/auth/responses/update_user.txt`
- `docs/api/v1/auth/responses/forgot_password.txt`
- `docs/api/v1/auth/responses/logout.txt`

Comando:

```bash
bin/rails runner script/generate_auth_examples.rb
```
