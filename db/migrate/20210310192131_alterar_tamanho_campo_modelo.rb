class AlterarTamanhoCampoModelo < ActiveRecord::Migration[5.2]
  def change
    change_column :funcaos, :nm_modelo, :string, limit: 20
  end
end
