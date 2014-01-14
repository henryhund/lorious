class AvailableTag < ActiveRecord::Base

  scope :skills, -> { where(category: "Skills") }
  scope :problems, -> { where(category: "Problems") }
  
  def category_enum
    ["Skills","Problems"]
  end

end
