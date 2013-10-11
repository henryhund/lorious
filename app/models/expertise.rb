class Expertise < ActiveRecord::Base
  belongs_to :expert

  validates :title, :description, presence: true
end
