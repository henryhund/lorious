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
  
  searchable :auto_index => true, :auto_remove => true do
    
    string :problems, :multiple => true, :stored => true do
      problems.map{|c| c.value.downcase.strip}
    end
    
    string :skill_list, :multiple => true, :stored => true do 
      skill_list.map!{|c| c.downcase.strip}
    end
    
  end
  
  def attributes
    super.merge({'skill_list' => skill_list, 'requester_name' => requester_name})
  end
  
  def create_problem_type(problem_type)
    self.problems.create(:value => problem_type)
  end
  
  def self.get_unique_problem_types
    Problem.uniq.pluck(:value)
  end
  
  def get_requester_name()
    self.requester.try(:name) rescue "Unknown"
  end

  alias_method :requester_name, :get_requester_name
end
