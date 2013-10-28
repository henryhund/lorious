class AddTransactIdtoCreditTransaction < ActiveRecord::Migration
  def change
     add_column :credit_transactions, :transacter_id, :integer
     add_column :credit_transactions, :transacted_id, :integer
  end
end
