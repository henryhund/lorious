class AddUserConfirmedToAppointment < ActiveRecord::Migration
  
  def up
    add_column :appointments, :user_confirmed, :boolean, default: true
    rename_column :appointments, :confirmed, :expert_confirmed
  end

  def down
    remove_column :appointments, :user_confirmed
    rename_column :appointments, :expert_confirmed, :confirmed
  end

end
