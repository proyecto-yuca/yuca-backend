# Alertas API — Guía de integración

Base URL: `http://localhost:3000`. Requiere autenticación (`Authorization: Bearer <TOKEN>`) y el permiso `mediciones:ver`.

Una **alerta** se crea automáticamente cuando una lectura sale del rango de un evento de su variable (ver [`variables/INTEGRATION.md`](../variables/INTEGRATION.md#6-eventos-de-tolerancia)). Este endpoint es de solo lectura.

---

## Listar alertas de una finca

```bash
curl -X GET "http://localhost:3000/api/v1/fincas/8/alertas?severidad=critico&page=1&page_size=10" \
  -H "Authorization: Bearer $TOKEN"
```

| Parámetro | Descripción |
|-----------|-------------|
| `sensor_id` | Solo alertas de ese sensor |
| `variable_id` | Solo alertas de esa variable |
| `evento_id` | Solo alertas de ese evento |
| `severidad` | `alerta` o `critico` |
| `fecha_desde` + `fecha_hasta` | Rango por fecha de la lectura (`YYYY-MM-DD`, ambos obligatorios) |
| `page`, `page_size` | Default `1` y `10`; máximo `100` |

Ordenadas de la más reciente a la más antigua.

**Respuesta `200 OK`:**

```json
{
  "data": [
    {
      "id": "12",
      "tipo": "alto",
      "severidad": "critico",
      "valor": 95.2,
      "rango": { "min": 30.0, "max": 90.0 },
      "evento": { "id": "2", "nombre": "Humedad crítica" },
      "variable": { "id": "1", "nombre": "Humedad", "unidad": "%" },
      "sensor": { "id": "3", "codigo": "LS-SHT-01", "nombre": "Sensor Humedad Sur" },
      "cultivo": { "id": "2", "nombre": "Lote Sur" },
      "fecha": "2026-09-28",
      "horaRegistro": "14:00",
      "envio": {
        "enviadoAt": "2026-09-28T19:00:04Z",
        "emails": ["agronomo@yuca.com", "gerencia@yuca.com"],
        "omitido": false,
        "motivoOmision": null,
        "error": null
      },
      "createdAt": "2026-09-28T19:00:03Z"
    }
  ],
  "total": 7, "page": 1, "pageSize": 10, "totalPages": 1
}
```

- `rango` es una **copia** del rango del evento cuando se disparó: no cambia si luego se edita el evento.
- `envio.motivoOmision`: `"intervalo"` (ya se avisó hace menos de `intervalo_minutos`), `"sin_correo"` (el evento no tiene correo activo) o `"sin_destinatarios"` (la lista estaba vacía al enviar).
- `envio.enviadoAt = null` con `omitido = false` y sin `error` significa que el correo está en cola.

---

## Correo local

En desarrollo los correos no salen a internet:

- **Bandeja local:** `http://localhost:3000/letter_opener` (correos reales enviados por el sistema).
- **Previews del diseño:** `http://localhost:3000/rails/mailers/alerta_mailer` (casos *critico*, *alerta* y *solo_maximo*, sin tocar la base).
- El botón *Ver lecturas del sensor* apunta a `FRONTEND_URL` (default `http://localhost:5173`) + `/dashboard/lecturas?finca=ID&sensor=ID`.
- Remitente: `MAIL_FROM` (default `Yuca Alertas <alertas@yuca.local>`).

El SMTP de producción está pendiente (ver GAPs en [`docs/PLAN_RANGOS_TOLERANCIA_2026_09_28.md`](../../PLAN_RANGOS_TOLERANCIA_2026_09_28.md)).
