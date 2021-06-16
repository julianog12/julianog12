class AddNewIndexToFuncaos < ActiveRecord::Migration[5.2]
  def change
   remove_index :funcaos, [:cd_componente, :nm_funcao, :cd_empresa]
   add_index :funcaos, [:cd_empresa, :cd_componente, :tipo, :nm_funcao, :nm_campo, :nm_tabela, :nm_modelo], unique: true, name: 'index_funcao_01'
  end
end
