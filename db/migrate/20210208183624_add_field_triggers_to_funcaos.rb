class AddFieldTriggersToFuncaos < ActiveRecord::Migration[5.2]
  def change
     add_column :funcaos, :nm_campo, :string, limit: 32
	 add_column :funcaos, :nm_tabela, :string, limit: 32
	 add_column :funcaos, :nm_modelo, :string, limit: 10
  end
end
