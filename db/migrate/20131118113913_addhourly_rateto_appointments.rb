class AddhourlyRatetoAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :hourly_rate, :decimal
  end
end
