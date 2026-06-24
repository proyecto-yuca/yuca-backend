puts "🔐 Creando módulos..."

modulos_data = [
  { identificador: "inicio",      nombre: "Inicio",      orden: 1 },
  { identificador: "fincas",      nombre: "Fincas",      orden: 2 },
  { identificador: "cultivos",    nombre: "Cultivos",    orden: 3 },
  { identificador: "sensores",    nombre: "Sensores",    orden: 4 },
  { identificador: "variables",   nombre: "Variables",   orden: 5 },
  { identificador: "mediciones",  nombre: "Mediciones",  orden: 6 },
  { identificador: "permisos",    nombre: "Permisos",    orden: 7 }
]

modulos = modulos_data.map do |data|
  Modulo.find_or_create_by!(identificador: data[:identificador]) do |m|
    m.nombre = data[:nombre]
    m.orden  = data[:orden]
  end
end

puts "   ✓ #{modulos.size} módulos creados"

# ─── Roles ───────────────────────────────────────────────────────────────────

puts "👥 Creando roles..."

roles_data = [
  { identificador: "admin",      nombre: "Administrador", descripcion: "Acceso total al sistema",  sistema: true },
  { identificador: "consultant", nombre: "Consultor",     descripcion: "Consultor agrícola",       sistema: true },
  { identificador: "owner",      nombre: "Propietario",   descripcion: "Dueño de fincas",          sistema: true },
  { identificador: "user",       nombre: "Usuario",       descripcion: "Usuario estándar",         sistema: true }
]

roles = roles_data.map do |data|
  Rol.find_or_create_by!(identificador: data[:identificador]) do |r|
    r.nombre      = data[:nombre]
    r.descripcion = data[:descripcion]
    r.sistema     = data[:sistema]
  end
end

puts "   ✓ #{roles.size} roles creados"

# ─── Permisos por rol ─────────────────────────────────────────────────────────

puts "🛡️  Asignando permisos..."

admin      = Rol.find_by!(identificador: "admin")
consultant = Rol.find_by!(identificador: "consultant")
owner      = Rol.find_by!(identificador: "owner")
user_rol   = Rol.find_by!(identificador: "user")

inicio     = Modulo.find_by!(identificador: "inicio")
fincas     = Modulo.find_by!(identificador: "fincas")
cultivos   = Modulo.find_by!(identificador: "cultivos")
sensores   = Modulo.find_by!(identificador: "sensores")
variables  = Modulo.find_by!(identificador: "variables")
mediciones = Modulo.find_by!(identificador: "mediciones")
permisos_m = Modulo.find_by!(identificador: "permisos")

todos_los_modulos = [ inicio, fincas, cultivos, sensores, variables, mediciones, permisos_m ]

# Admin: acceso total a todos los módulos
todos_los_modulos.each do |modulo|
  Permiso.find_or_create_by!(rol: admin, modulo: modulo) do |p|
    p.ver = p.crear = p.editar = p.eliminar = true
  end
end

# Consultor: solo ver en todos los módulos
todos_los_modulos.each do |modulo|
  Permiso.find_or_create_by!(rol: consultant, modulo: modulo) do |p|
    p.ver      = true
    p.crear    = false
    p.editar   = false
    p.eliminar = false
  end
end

# Propietario: gestión completa en fincas, sensores y mediciones; sin acceso al resto
modulos_owner = [ fincas, sensores, mediciones ]
todos_los_modulos.each do |modulo|
  full = modulos_owner.include?(modulo)
  Permiso.find_or_create_by!(rol: owner, modulo: modulo) do |p|
    p.ver      = full
    p.crear    = full
    p.editar   = full
    p.eliminar = full
  end
end

# Usuario estándar: sin permisos
todos_los_modulos.each do |modulo|
  Permiso.find_or_create_by!(rol: user_rol, modulo: modulo) do |p|
    p.ver      = false
    p.crear    = false
    p.editar   = false
    p.eliminar = false
  end
end

puts "   ✓ Permisos asignados"

# ─── Asignar rol owner a usuarios existentes ─────────────────────────────────

if User.where(rol_id: nil).exists?
  admin_rol = Rol.find_by!(identificador: "admin")
  User.where(rol_id: nil).update_all(rol_id: admin_rol.id)
  puts "   ✓ Rol 'admin' asignado a usuarios existentes sin rol"
end
