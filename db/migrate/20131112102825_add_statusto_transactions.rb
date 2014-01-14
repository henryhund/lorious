class AddStatustoTransactions < ActiveRecord::Migration
  def change
    add_column :credit_transactions, :transaction_status, :string
  end
end
