class CreateSidekiqjobs < ActiveRecord::Migration
  def change
    create_table :sidekiqjobs do |t|
      t.integer :sidekiq_id
      t.belongs_to :workable, polymorphic: true

      t.timestamps
    end
    
    add_index :sidekiqjobs, [:workable_id, :workable_type]
  end
end
