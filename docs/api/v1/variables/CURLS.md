# Variables — Ejemplos cURL

```bash
export TOKEN="eyJhbGci..."
```

---

### Listar variables

```bash
curl -X GET "http://localhost:3000/api/v1/variables" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Detalle de variable

```bash
curl -X GET "http://localhost:3000/api/v1/variables/1" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Crear variable

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

---

### Actualizar variable

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

---

### Eliminar variable

```bash
curl -X DELETE "http://localhost:3000/api/v1/variables/1" \
  -H "Authorization: Bearer $TOKEN"
```
