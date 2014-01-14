class AddHangoutUrLtoAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :hangout_url, :string
    add_column :appointments, :is_hangout_active, :boolean
  end
end
