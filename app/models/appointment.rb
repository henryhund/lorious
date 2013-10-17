class Appointment < ActiveRecord::Base
  belongs_to :expert
  belongs_to :user

  validates :subject, :description, :time, :duration, :place, presence: true
end
