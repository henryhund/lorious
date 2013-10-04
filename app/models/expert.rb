class Expert < User
  acts_as_taggable
  acts_as_taggable_on :skills

  attr_accessor :skills

  has_one :availability
  has_many :appointments, foreign_key: "expert_id"

  with_options if: :apply_for_expert_step_validation_required do |user|
    user.validates :job, :skills, presence: true
  end
  
  searchable do
    text :first_name
    text :bio
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
end
