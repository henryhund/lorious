class RemoveuseridFromCreditTransaction < ActiveRecord::Migration
  def change
    remove_column :credit_transactions, :user_id
  end
end
