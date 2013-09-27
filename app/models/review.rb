class Review < ActiveRecord::Base
  belongs_to :reviewed, class_name: "User"
  belongs_to :reviewer, class_name: "User"
end
