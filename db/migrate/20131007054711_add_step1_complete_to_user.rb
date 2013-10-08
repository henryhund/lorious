class AddStep1CompleteToUser < ActiveRecord::Migration
  def change
    add_column :users, :step_1_complete, :boolean, default: false
    add_column :users, :step_2_complete, :boolean, default: false
  end
end
