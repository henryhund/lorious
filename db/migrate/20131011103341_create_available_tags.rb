class CreateAvailableTags < ActiveRecord::Migration
  def change
    create_table :available_tags do |t|
      t.string :name
      t.string :category

      t.timestamps
    end
  end
end
