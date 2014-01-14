class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :value

      t.timestamps
    end
    
    create_table 'problems_requests', :id => false do |t|
      t.column :request_id, :integer
      t.column :problem_id, :integer
    end
    
  end
end
