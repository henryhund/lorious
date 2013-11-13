class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      
      t.string :name
      t.string :value
      t.index :name
    end
  end
end
