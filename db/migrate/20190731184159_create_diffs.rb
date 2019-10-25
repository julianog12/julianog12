class CreateDiffs < ActiveRecord::Migration[5.2]
  def change
    create_table :diffs do |t|

      t.timestamps
    end
  end
end
