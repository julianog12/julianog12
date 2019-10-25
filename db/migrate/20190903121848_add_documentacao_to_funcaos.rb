class AddDocumentacaoToFuncaos < ActiveRecord::Migration[5.2]
  def change
    add_column :funcaos, :documentacao, :text
  end
end
