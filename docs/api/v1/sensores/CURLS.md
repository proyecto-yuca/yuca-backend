# Sensores — Ejemplos cURL

```bash
export TOKEN="eyJhbGci..."
export FINCA_ID="1"
```

---

### Listar sensores de una finca

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/$FINCA_ID/sensores" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Detalle de sensor

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/$FINCA_ID/sensores/1" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Crear sensor

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/$FINCA_ID/sensores" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "sensor": {
      "codigo": "SHT-3x-A",
      "nombre": "Sensor Humedad Norte",
      "descripcion": "Sensor instalado en la zona norte del cultivo.",
      "lat": 4.3372,
      "lng": -74.3641,
      "cultivo_id": "1",
      "variable_ids": ["1", "2"]
    }
  }'
```

**Sin posición ni cultivo:**

```bash
curl -X POST "http://localhost:3000/api/v1/fincas/$FINCA_ID/sensores" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "sensor": {
      "codigo": "BME-280-B",
      "nombre": "Sensor Temperatura Sur",
      "variable_ids": ["2"]
    }
  }'
```

**Respuesta `201 Created`:**

```json
{
  "id": "1",
  "codigo": "SHT-3x-A",
  "nombre": "Sensor Humedad Norte",
  "descripcion": "Sensor instalado en la zona norte del cultivo.",
  "posicion": { "lat": 4.3372, "lng": -74.3641 },
  "activo": true,
  "cultivo": { "id": "1", "nombre": "Yuca ICA Costeña" },
  "variables": [
    { "id": "1", "nombre": "Humedad", "unidad": "%" },
    { "id": "2", "nombre": "Temperatura", "unidad": "°C" }
  ],
  "fincaId": "1",
  "createdAt": "2026-06-24T21:15:31Z",
  "updatedAt": "2026-06-24T21:15:31Z"
}
```

---

### Actualizar sensor

```bash
curl -X PATCH "http://localhost:3000/api/v1/fincas/$FINCA_ID/sensores/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "sensor": {
      "nombre": "Sensor Humedad Norte — Actualizado",
      "variable_ids": ["1", "2", "3"]
    }
  }'
```

---

### Activar / desactivar sensor

No requiere body. Alterna entre `activo: true` y `activo: false`.

```bash
curl -X PATCH "http://localhost:3000/api/v1/fincas/$FINCA_ID/sensores/1/toggle" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Eliminar sensor

```bash
curl -X DELETE "http://localhost:3000/api/v1/fincas/$FINCA_ID/sensores/1" \
  -H "Authorization: Bearer $TOKEN"
```
