class AddisReviewedtoAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :is_reviewed, :boolean, :default => false
  end
end
