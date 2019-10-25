class CreateFuncaos < ActiveRecord::Migration[5.2]
  def change
    create_table :funcaos do |t|
      t.string :nm_funcao, limit: 100
      t.string :cd_componente
      t.string :tipo, limit: 20
      t.text :codigo
      t.string :cd_empresa, limit: 3

      t.timestamps
    end

    add_index :funcaos, [:cd_componente, :nm_funcao, :cd_empresa], unique: true
  end
end
