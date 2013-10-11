class CreateCreditTransactions < ActiveRecord::Migration
  def change
    create_table :credit_transactions do |t|
      t.integer :amount
      t.boolean :added
      t.references :user, index: true

      t.timestamps
    end
  end
end
