class AddNrLinhasToFuncaos < ActiveRecord::Migration[5.2]
  def change
    add_column :funcaos, :nr_linhas, :integer, defaul: 0
  end
end
