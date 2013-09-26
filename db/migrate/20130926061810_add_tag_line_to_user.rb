class AddTagLineToUser < ActiveRecord::Migration
  def change
    add_column :users, :tag_line, :string
    add_column :users, :bio, :text
    add_column :users, :location, :string
    add_column :users, :website, :string
    add_column :users, :image, :string
  end
end
