class AddSocialMediatoExpert < ActiveRecord::Migration
  def change
    add_column :users, :github_url, :string
    add_column :users, :stack_overflow_url, :string
    add_column :users, :linked_in_url, :string
    add_column :users, :personal_website, :string
  end
end
