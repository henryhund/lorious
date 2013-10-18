class Appointment < ActiveRecord::Base
  belongs_to :expert
  belongs_to :user

  validates :subject, :description, :time, :duration, presence: true
  validates :place, presence: true, if: :in_person_meet?

  def total_credit_cost
    (expert.hourly_rate_in_credit * duration / 60.to_f).ceil
  end

  def in_person_meet?
    !online
  end
end
