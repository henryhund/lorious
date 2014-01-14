class AddRequestIdToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :request_id, :integer
  end
end
