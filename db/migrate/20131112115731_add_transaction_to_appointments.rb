class AddTransactionToAppointments < ActiveRecord::Migration
  def change
      add_column :appointments, :transaction_id, :integer
  end
end
