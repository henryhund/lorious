class AddApptStatetoAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :appt_state, :string, :default => "new"
  end
end
