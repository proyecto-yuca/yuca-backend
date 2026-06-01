# Integracion API IoT (v1)

Estos endpoints permiten provisionar credenciales para un dispositivo IoT y sincronizar lecturas de sensores sin usar JWT de usuario.

## 1) Provisionar credenciales IoT por finca

Solo usuarios autenticados (JWT) pueden crear o rotar credenciales.

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/{FINCA_ID}/iot/credential" \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json"
```

Respuesta:

```json
{
  "fincaId": "1",
  "clientId": "iot_6a7f...",
  "secretId": "sec_13bd...",
  "active": true
}
```

> `secretId` solo se retorna al crear/rotar credenciales. Guardalo en el dispositivo.

## 2) Sincronizar lecturas de sensores

Endpoint para dispositivos IoT bajo `v1/iot/...`.

```bash
curl -X POST "http://localhost:3000/api/v1/iot/lecturas_sensor/sync" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "iot-demo-1",
    "secret_id": "iot-secret-demo-1",
    "lecturas": [
      {
        "sensor_id": "SHT-31B",
        "fecha": "2026-06-01",
        "hora_registro": "06:00",
        "humedad": 67.4,
        "temperatura": 24.2
      },
      {
        "sensor_id": "SHT-31B",
        "fecha": "2026-06-01",
        "hora_registro": "12:00",
        "humedad": 63.2,
        "temperatura": 29.4
      }
    ]
  }'
```

Tambien se pueden enviar credenciales por headers:

- `X-Client-Id`
- `X-Secret-Id`

Ejemplo con headers:

```bash
curl -X POST "http://localhost:3000/api/v1/iot/lecturas_sensor/sync" \
  -H "Content-Type: application/json" \
  -H "X-Client-Id: iot-demo-1" \
  -H "X-Secret-Id: iot-secret-demo-1" \
  -d '{
    "lecturas": [
      {
        "sensor_id": "SHT-31B",
        "fecha": "2026-06-01",
        "hora_registro": "18:00",
        "humedad": 61.0,
        "temperatura": 27.9
      }
    ]
  }'
```

Respuesta:

```json
{
  "finca_id": 1,
  "sync_at": "2026-06-01T19:10:40.000Z",
  "stats": {
    "received": 2,
    "created": 2,
    "duplicated": 0,
    "failed": 0
  },
  "errors": []
}
```

## Reglas importantes

- `client_id` y `secret_id` son obligatorios.
- Las lecturas se asocian automaticamente a la finca propietaria del `client_id`.
- Si llega una lectura con misma `fecha` + `hora_registro` para la misma finca, se marca como `duplicated`.
- El campo `estado` se calcula automaticamente con la logica actual del modelo `LecturaSensor`.
- El valor `secret_id_digest` en base de datos es solo interno; en requests siempre usa `secret_id` en texto plano.
