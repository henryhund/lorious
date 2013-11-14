class AddFeaturedtoExperts < ActiveRecord::Migration
  def change
    add_column :users, :is_featured, :boolean, :default => false
  end
end
