class AddTransactionIDtocredits < ActiveRecord::Migration
  def change
    add_column :credit_transactions, :transaction_id, :string
  end
end
