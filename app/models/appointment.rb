class Appointment < ActiveRecord::Base
  
  acts_as_taggable
  acts_as_taggable_on :skills
  
  belongs_to :expert
  belongs_to :user

  attr_accessor :what_message, :tos_accepted, :check_valid
  validates :subject, :time, :duration, presence: true
  validates_presence_of :what_message, :message => "Please enter text in the field labeled 'What'." , :if => :skip_form_field_validation?
  validates_acceptance_of :tos_accepted, :message => "Please Accept the terms and conditions." , :if => :skip_form_field_validation?
  
  validate :time_cannot_be_in_the_past, :check_minimum_transaction_amount, :if => :skip_form_field_validation?

  scope :pending, -> { where("appt_state = 'new' AND time > ? AND (expert_confirmed = false OR user_confirmed = false OR expert_confirmed is NULL OR user_confirmed is NULL)", Time.now) }
  scope :upcoming, -> { where("expert_confirmed = true AND user_confirmed = true AND time >= ?", Time.now) }
  scope :history, -> { where("appt_state = 'cancelled' OR expert_confirmed = true AND user_confirmed = true AND time < ?", Time.now) }

  belongs_to :request
  belongs_to :credit_transaction, foreign_key: "transaction_id"
  
  has_many :sidekiqjobs, as: :workable
  
  has_one :review
  
  def skip_form_field_validation?
    self.check_valid ||= false
  end 
  
  def total_credit_cost
    (expert.hourly_rate_in_credit * duration / 60.to_f).ceil
  end

  def duration_in_words
    duration < 60 ? "#{duration.to_s} minutes" : "#{(duration/60.round(1)).to_s} #{"hour".pluralize(duration/60.round(1))}"
  end
  
  def in_person_meet?
    !online
  end

  def appointment_with_for_user for_user
    if for_user == self.expert
      user
    else
      expert
    end
  end

  def confirmed?
    user_confirmed && expert_confirmed
  end
  
  def check_minimum_transaction_amount
    errors.add(:base, "Appointment transaction is less than minimum value allowed.") if
      total_credit_cost < Setting.find_by(name: "minimum_transaction_amount").value.to_i
  end
  
  def time_cannot_be_in_the_past
    errors.add(:time, "of Appointment can't be in the past") if
      !time.blank? and time < Date.today
  end
  
  def time_local
    time = time.in_time_zone(time_zone)
  end

end
