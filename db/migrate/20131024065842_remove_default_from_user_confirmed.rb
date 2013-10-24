class RemoveDefaultFromUserConfirmed < ActiveRecord::Migration
  def up
    change_column :appointments, :user_confirmed, :boolean, default: nil
  end

  def down
    change_column :appointments, :user_confirmed, :boolean, default: true
  end
end
