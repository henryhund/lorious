class AddBraintreeIdtoUser < ActiveRecord::Migration
  def change
      add_column :users, :braintree_id, :string
      add_column :users, :braintree_last4, :string
  end
end
