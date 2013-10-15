class AddDescriptionZipToRequets < ActiveRecord::Migration
  def change
    add_column :requests, :company_description, :text
    add_column :requests, :problem_description, :text
    add_column :requests, :local_zip, :string
  end
end
