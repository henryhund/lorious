class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :name
      t.string :email
      t.boolean :approved, default: false

      t.timestamps
    end
  end
end
