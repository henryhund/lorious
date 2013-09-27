class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.datetime :time
      t.integer :duration
      t.string :place
      t.boolean :confirmed, default: false
      t.integer :expert_id
      t.integer :user_id

      t.timestamps
    end
  end
end
