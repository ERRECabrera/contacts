class CreateRelations < ActiveRecord::Migration[5.1]
  def change
    create_table :relations do |t|
      t.belongs_to :user, foreign_key: true
      t.bigint :contact_id
      t.integer :_type

      t.timestamps
    end
    add_index :relations, :_type
  end
end
