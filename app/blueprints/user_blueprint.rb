class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :email, :estado, :created_at, :updated_at

  association :rol, blueprint: RolBlueprint
end
