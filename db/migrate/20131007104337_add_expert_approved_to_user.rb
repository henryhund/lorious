class AddExpertApprovedToUser < ActiveRecord::Migration
  def change
    add_column :users, :expert_approved, :boolean, :default: false
  end
end
