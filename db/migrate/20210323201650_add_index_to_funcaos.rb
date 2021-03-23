class AddIndexToFuncaos < ActiveRecord::Migration[5.2]
  def change
    add_index :funcaos, [:cd_empresa, :nm_modelo], name: 'index_funcao_02'
  end
end
