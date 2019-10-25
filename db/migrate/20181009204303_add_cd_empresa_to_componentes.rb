class AddCdEmpresaToComponentes < ActiveRecord::Migration[5.2]
  def change
    add_column :componentes, :cd_empresa, :string, limit: 3
  end
end
