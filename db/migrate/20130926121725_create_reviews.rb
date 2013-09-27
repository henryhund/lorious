class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :reviewer_id
      t.integer :reviewed_id
      t.float :rating
      t.text :content

      t.timestamps
    end
  end
end
