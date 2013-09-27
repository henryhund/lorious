class Appointment < ActiveRecord::Base
  belongs_to :expert
  belongs_to :user
end
