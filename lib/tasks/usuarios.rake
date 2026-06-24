namespace :usuarios do
  desc "Asigna el rol 'admin' a todos los usuarios que no tienen rol asignado"
  task asignar_rol_admin: :environment do
    admin = Rol.find_by(identificador: "admin")

    abort "ERROR: Rol 'admin' no encontrado. Corre primero db:seed." unless admin

    usuarios = User.where(rol_id: nil)

    if usuarios.none?
      puts "Todos los usuarios ya tienen rol asignado."
      next
    end

    usuarios.update_all(rol_id: admin.id)
    puts "✓ Rol 'admin' asignado a #{usuarios.count} usuario(s):"
    usuarios.each { |u| puts "  - #{u.email}" }
  end
end
