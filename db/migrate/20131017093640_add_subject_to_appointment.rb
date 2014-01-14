class AddSubjectToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :subject, :string
    add_column :appointments, :description, :text
    add_column :appointments, :online, :boolean
  end
end
