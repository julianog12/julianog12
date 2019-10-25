class AddTipoToComponentes < ActiveRecord::Migration[5.2]
  def change
    add_column :componentes, :tipo, :string, limit: 32
  end
end
