class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :requester_id
      t.integer :requested_id
      t.string :company_name
      t.string :company_url
      t.integer :appt_length
      t.boolean :is_local
      t.boolean :is_online
      t.string :request_state

      t.timestamps
    end
  end
end
