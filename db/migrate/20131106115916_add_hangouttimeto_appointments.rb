class AddHangouttimetoAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :hangout_start_time, :datetime
  end
end
