class CreateExpertises < ActiveRecord::Migration
  def change
    create_table :expertises do |t|
      t.string :title
      t.text :description
      t.references :expert, index: true

      t.timestamps
    end
  end
end
