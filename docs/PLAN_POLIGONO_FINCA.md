# Plan: Polígono de la finca y cultivos contenidos en la finca

> **Estado: implementado el 2026-09-28.** Detalle de lo realizado en [SESION_2026_09_28.md](./SESION_2026_09_28.md).
> Cambio respecto al plan: el mapa de **sensores** también dibuja el área de la finca, y si el sensor no tiene cultivo se limita a la finca.

## Objetivo

Permitir registrar los **4 puntos (vértices) de la finca**, dibujarlos en el mapa y garantizar que los **puntos de cada cultivo queden dentro del polígono de la finca**.

---

## Situación actual

| Entidad | Campo | Tipo | Observación |
|---------|-------|------|-------------|
| `Finca` | `coordenadas` | `string` | Texto libre (ej. `"4.3372° N, 74.3641° W"`), no sirve para dibujar un área |
| `Cultivo` | `puntos_ubicacion` | `jsonb` | Hasta 4 puntos `{lat, lng}`, ya se dibujan en Google Maps (`CultivoLocationMap`) |

En el frontend ya existe la regla "sensor dentro del cultivo" (`yuca-frontend/src/lib/mapGeometry.ts` → `orderPolygonPoints`, `isPointInPolygon`, usada en `SensorLocationMap.tsx` y `SensoresPage.tsx`). Se reutiliza el mismo patrón un nivel arriba (cultivo dentro de finca) y **además se valida en el backend**.

---

## Decisiones

- `puntos_ubicacion` de finca es **opcional en backend** (las fincas existentes no tienen). Si se envía: arreglo, máximo 4 puntos, `lat`/`lng` numéricos.
- En el formulario del frontend se exigen **3–4 puntos** (igual que cultivos).
- La validación de contención solo aplica si la finca tiene **≥ 3 puntos**.
- El campo `coordenadas` (string) se mantiene sin cambios.
- Formato de entrada `puntos_ubicacion` (snake_case) y salida `puntosUbicacion` (camelCase), igual que cultivos.

---

## Tareas — Backend (yuca-backend)

### 1. Migración

```ruby
class AddPuntosUbicacionToFincas < ActiveRecord::Migration[8.1]
  def change
    add_column :fincas, :puntos_ubicacion, :jsonb, default: [], null: false
  end
end
```

**Archivo:** `db/migrate/2026XXXXXXXXXX_add_puntos_ubicacion_to_fincas.rb` (+ `db/schema.rb` vía `bin/rails db:migrate`)

---

### 2. Concern `PuntosUbicacion`

- Mover aquí la validación actual de `Cultivo#puntos_ubicacion_validos` (arreglo, ≤ 4 puntos, `lat`/`lng` numéricos) para compartirla entre `Finca` y `Cultivo`.
- `poligono` → puntos como `Float`, ordenados angularmente alrededor del centroide (port de `orderPolygonPoints` para que backend y frontend den el mismo resultado). Devuelve `[]` si hay menos de 3 puntos.
- `contiene_punto?(lat, lng)` → ray casting (port de `isPointInPolygon`).

**Archivo:** `app/models/concerns/puntos_ubicacion.rb`

---

### 3. Modelo `Finca`

- `include PuntosUbicacion`.
- Nueva validación `cultivos_dentro_del_poligono`: si cambió `puntos_ubicacion` y el polígono tiene ≥ 3 puntos, error si algún cultivo existente queda con puntos fuera → `"el cultivo X quedaría fuera del área de la finca"`.

**Archivo:** `app/models/finca.rb`

---

### 4. Modelo `Cultivo`

- `include PuntosUbicacion` (eliminar la validación duplicada).
- Nueva validación `dentro_de_la_finca`: si `finca.poligono.size >= 3`, cada punto debe cumplir `finca.contiene_punto?` → `"punto N está fuera del área de la finca"`.

**Archivo:** `app/models/cultivo.rb`

---

### 5. `FincasController`

- `finca_params`: permitir `puntos_ubicacion: [ :lat, :lng ]` (top-level; `flatten_nested_params` lo conserva vía `except`).
- `serialize_finca`: agregar `puntosUbicacion` con el mismo mapeo a `float` que `CultivosController#serialize_cultivo`.

**Archivo:** `app/controllers/api/v1/fincas_controller.rb`

---

### 6. Seeds

- En `db/seeds/lecturas_el_porvenir.rb`, antes de crear `Lote Norte` y `Lote Sur`, asignar a "Agrícola El Porvenir" 4 puntos que encierren ambos cultivos (ej. lat `3.5350–3.5425`, lng `-76.3060 – -76.3015`).
- Opcional: agregar 4 puntos alrededor de `coordenadas` al resto de fincas en `db/seeds.rb`.

---

### 7. Documentación

- `docs/api/v1/fincas/INTEGRATION.md`: nuevo campo, ejemplos de request/response y errores `422`.
- `docs/api/v1/cultivos/INTEGRATION.md`: nuevo `422` "punto N está fuera del área de la finca".

---

### 8. Tests

`test/models/finca_test.rb` y `test/models/cultivo_test.rb`:

- Más de 4 puntos → inválido.
- Punto no numérico → inválido.
- Cultivo dentro de la finca → válido; fuera → inválido.
- Finca sin polígono → no se valida contención.
- Editar la finca dejando un cultivo fuera → inválido.

---

## Tareas — Frontend (yuca-frontend)

### 1. Tipos y servicio

- `src/types/fincas.types.ts`: `puntosUbicacion: PuntoUbicacion[]` en `Finca`; `puntosUbicacion: { lat: string; lng: string }[]` en `FincaFormData`.
- `src/services/fincas/fincasService.ts`: enviar `puntos_ubicacion` (mismo formato que `cultivosService`).

### 2. Mapa reutilizable

Generalizar `src/pages/cultivos/CultivoLocationMap.tsx` → `src/components/maps/PolygonPointsMap.tsx`, con prop opcional `boundaryPoints?: LatLng[]`:

- Dibuja el polígono de la finca como borde de referencia (otro color / punteado) y el polígono propio encima (patrón de `SensorLocationMap`).
- Clic o arrastre fuera del borde (si tiene ≥ 3 puntos) se rechaza con aviso *"El cultivo debe ubicarse dentro del área de la finca"*.
- El ajuste de zoom (`FitToPoints`) incluye los puntos de la finca.

### 3. `FincasPage`

- En `LoteForm`: nueva sección **"Área de la finca"** con el mapa y lista editable de hasta 4 puntos (misma UX que cultivos: agregar / mover / eliminar, inputs `lat`/`lng`).
- `fincaToForm`, estado vacío y `validateForm` (3–4 puntos válidos) incluyen `puntosUbicacion`.
- Mostrar el polígono en el modal de detalle.

### 4. `CultivosPage`

- Pasar `boundaryPoints={selectedFinca.puntosUbicacion}` al mapa.
- `validateForm`: rechazar puntos fuera del polígono de la finca (igual que `SensoresPage.validateForm`).
- Mostrar los errores `422` del backend.

---

## Verificación

**Backend**
```bash
bin/rails db:migrate
bin/rails test
bin/rails db:seed
```

**curl**
- `PATCH /api/v1/fincas/:id` con 4 puntos → `200` con `puntosUbicacion`.
- `POST /api/v1/fincas/:id/cultivos` con un punto fuera → `422`; todos dentro → `201`.
- `PATCH /api/v1/fincas/:id` achicando el polígono y dejando un cultivo fuera → `422`.

**Frontend**
```bash
npm run lint && npm run build
```
En `npm run dev`: dibujar la finca (4 clics), abrir sus cultivos, ver el polígono de la finca y confirmar que clics fuera se rechazan y dentro se aceptan.
