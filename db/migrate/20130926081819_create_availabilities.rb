class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.references :expert, index: true
      t.text :timespans
      t.float :hourly_cost
      t.integer :timezone_in_minutes

      t.timestamps
    end
  end
end
