class Expert < User
  acts_as_taggable
  acts_as_taggable_on :skills

  has_one :availability

  def set_availability(availability, timezone_in_minutes, availability_unit_in_minutes=30)
    availability_object = self.build_availability
    availability_object.set_availability_in_gmt(availability, timezone_in_minutes, availability_unit_in_minutes)
    availability_object.save
    availability_object
  end

  def get_availability(availability, timezone_in_minutes)
    self.availability.is_free?(availability, timezone_in_minutes)
  end
end
