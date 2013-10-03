class CreateSocialMedia < ActiveRecord::Migration
  def change
    create_table :social_media do |t|
      t.string :name
      t.string :profile
      t.text :data
      t.references :user, index: true

      t.timestamps
    end
  end
end
