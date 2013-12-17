class RemoveDeleteRecordFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :delete_record
  end

  def down
    add_column :users, :delete_record, :boolean
  end
end
