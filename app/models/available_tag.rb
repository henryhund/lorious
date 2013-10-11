class AvailableTag < ActiveRecord::Base

  scope :skills, -> { where(category: "skills") }

  def category_enum
    ["Skills"]
  end

end
