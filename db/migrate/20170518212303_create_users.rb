class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :surnames, array: true
      t.string :email, :unique => true
      t.string :phones, array: true, default: []
      t.binary :avatar

      t.timestamps
    end
  end
end
