class AddAppointmenttoReview < ActiveRecord::Migration
  def change
    add_column :reviews, :appointment_id, :integer
  end
end
