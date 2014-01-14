class AddConversationIDtoAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :message_id, :integer 
  end
end
