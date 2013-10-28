class AddDescriptiontoCreditTransactions < ActiveRecord::Migration
  def change
    add_column :credit_transactions, :description, :text
  end
end
