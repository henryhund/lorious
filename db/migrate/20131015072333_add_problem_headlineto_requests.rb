class AddProblemHeadlinetoRequests < ActiveRecord::Migration
  def change
    add_column :requests, :problem_headline, :string
  end
end
