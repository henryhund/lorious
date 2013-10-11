class Request < ActiveRecord::Base
  
  def self.APPT_LENGTH 
    [10,15,20,25,30,35,40,45]
  end

  belongs_to :requester, class_name: "User"
  belongs_to :requested, class_name: "User"
  
  has_and_belongs_to_many :problems
  
  acts_as_taggable
  acts_as_taggable_on :skills
  
  attr_accessor     :other_problem_type
  
  validates_presence_of :company_name, :company_url
  
  validates_format_of :company_url, :with => /((?:https?\:\/\/|www\.)(?:[-a-z0-9]+\.)*[-a-z0-9]+.*)/i
  
  def create_problem_type(problem_type)
    self.problems.create(:value => problem_type)
  end
end
