class AddMerchantdetailstoUser < ActiveRecord::Migration
  def change
    add_column :users, :braintree_merchant_id, :string
    add_column :users, :braintree_merchant_status, :string
    add_column :users, :braintree_merchant_status_message, :text
  end
end
