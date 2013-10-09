class Request < ActiveRecord::Base
  belongs_to :requester, class_name: "User"
  belongs_to :requested, class_name: "User"
  
  has_and_belongs_to_many :problems
  
  acts_as_taggable
  acts_as_taggable_on :skills
  
  attr_accessor           :other_problem_type
  
end
