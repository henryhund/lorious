class Review < ActiveRecord::Base
  belongs_to :reviewed, class_name: "User"
  belongs_to :reviewer, class_name: "User"
  
  belongs_to :appointment
  
  validates_presence_of :content
  validates_length_of :content, :maximum => 500
  
  acts_as_taggable
  acts_as_taggable_on :tags
end
