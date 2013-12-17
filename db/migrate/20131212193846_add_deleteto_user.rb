class AddDeletetoUser < ActiveRecord::Migration
  def change
    add_column :users, :delete_record, :boolean
  end
end
