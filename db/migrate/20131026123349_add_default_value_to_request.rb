class AddDefaultValueToRequest < ActiveRecord::Migration
  def up
    change_column :requests, :request_state, :string, :default => "new"
  end
  def down
    change_column :requests, :request_state, :string, :default => nil
  end
end
