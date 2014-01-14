class AboutyourselftoExperts < ActiveRecord::Migration
  def change
    add_column :users, :about_description, :text
  end
end
