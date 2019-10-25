class CreateComponentes < ActiveRecord::Migration[5.2]
  def change
    create_table :componentes do |t|
      t.string :nome
      t.text :linha
      t.timestamps
    end
  end
end
