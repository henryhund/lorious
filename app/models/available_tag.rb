class AvailableTag < ActiveRecord::Base

  scope :skills, -> { where(category: "Skills") }

  def category_enum
    ["Skills"]
  end

end
