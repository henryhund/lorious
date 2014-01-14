class AddisExpertAppliedtoExpert < ActiveRecord::Migration
  def change
    add_column :users, :is_expert_applied, :boolean
  end
end
