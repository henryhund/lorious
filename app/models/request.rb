class Request < ActiveRecord::Base
  
  default_scope order('created_at DESC')
  
  def self.APPT_LENGTH 
    (30..360).step(30).map { |d| [ d < 60 ? "#{d.to_s} minutes" : "#{(d/60.round(1)).to_s} #{"hour".pluralize(d/60.round(1))}" , d.to_s ] }
  end

  belongs_to :requester, class_name: "User"
  belongs_to :requested, class_name: "User"
  has_many :appointments
  
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
    
    time :created_at
  end
  
  def attributes
    super.merge({'skill_list' => skill_list, 'requester_name' => requester_name, 'appt_length_in_words' => appt_length_in_words, 'requester_image' => requester_image})
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
  
  def appt_length_in_words()
    self.appt_length < 60 ? "#{self.appt_length.to_s} minutes" : "#{(self.appt_length/60.round(1)).to_s} #{"hour".pluralize(self.appt_length/60.round(1))}"
  end
  
  def get_requester_image_url()
    self.requester.try(:image) rescue ""
  end
  
  def get_recommended_experts_mail()
    experts = []
    self.skill_list.each do |tag|
      Expert.all.each do |expert|
        if expert.skill_list.include? tag
          experts.push(expert.email)
        end
      end
    end
    return experts.join(",")
  end
  
  alias_method :requester_name, :get_requester_name
  alias_method :requester_image, :get_requester_image_url
  after_initialize :set_default_state
  
  private 
    def set_default_state
      if new_record?
        self.request_state = "new" if self.request_state.nil?  
      end
    end

end
