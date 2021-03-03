class CreateConfiguracaos < ActiveRecord::Migration[5.2]
  def change
    create_table :configuracaos do |t|
	  t.string :cd_empresa, limit: 2
      t.string :parametro, limit: 50
	  t.string :valor, limit: 400
      t.timestamps
    end
  end
end
