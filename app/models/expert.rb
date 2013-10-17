class Expert < User
  acts_as_taggable
  acts_as_taggable_on :skills

  CASH_TO_CREDIT_RATIO = 1.0

  attr_accessor :skills
  
  has_one :availability
  has_many :appointments, foreign_key: "expert_id"
  has_many :expertise

  with_options if: :apply_for_expert_step_validation_required do |user|
    user.validates :job, presence: true
  end

  with_options if: :apply_for_expert_page? do |user|
    user.validates :skills, presence: true
  end
  
  searchable :auto_index => true, :auto_remove => true do
    text :first_name
    text :last_name
    text :bio
    string :skill_list, :multiple => true, :stored => true do 
      skill_list.map!{|c| c.downcase.strip}
    end
    latlon(:location) { 
       Sunspot::Util::Coordinates.new(self.latitude, self.longitude)
     }
  end
  
  def attributes
    super.merge({'skill_list' => skill_list, 'hourly_rate' => hourly_rate, 'average_rating' => average_rating})
  end
  
  def set_availability(availability, timezone_in_minutes, availability_unit_in_minutes=30)
    availability_object = self.build_availability
    availability_object.set_availability_in_gmt(availability, timezone_in_minutes, availability_unit_in_minutes)
    availability_object.save
    availability_object
  end

  def get_availability(availability, timezone_in_minutes)
    self.availability.is_free?(availability, timezone_in_minutes)
  end

  def apply_for_expert_step_validation_required
    validation_required? "apply_for_expert"
  end
  
  def get_hourly_rate()
    self.availability.try(:hourly_cost) || 0.00
  end
  
  def get_average_rating()
    Review.average('rating', :conditions => {:reviewed_id => self.id})
  end

  def hourly_rate_in_credit
    (hourly_rate / CASH_TO_CREDIT_RATIO).ceil()
  end

  alias_method :average_rating, :get_average_rating
  alias_method :hourly_rate, :get_hourly_rate
  
end
