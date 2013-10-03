class AddUsernameToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, unique: true
    add_column :users, :zip_code, :string
  end
end
