class AddCancellationtoCreateTransactions < ActiveRecord::Migration
  def change
    add_column :credit_transactions, :is_request_cancel, :boolean
    add_column :credit_transactions, :is_request_hold, :boolean
    add_column :credit_transactions, :request_cancel_reason, :text
    add_column :credit_transactions, :transaction_escrow_status, :string
  end
end
