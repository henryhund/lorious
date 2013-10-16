class Invite < ActiveRecord::Base

  validates :name, :email, presence: true
  validates_format_of :name, 
          :with => /\A[a-zA-Z\s]+\z/ix,
          :message => "only letters allowed"
  validates_format_of :email,
          :with => /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/ix,
          :message => "invalid email address"

  before_create :generate_token

  scope :approved, -> { where(approved: true) }

  after_save do
    if approved_changed? && approved
      UserMailer.invite_approved(self).deliver
    end
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(token: random_token)
    end
  end
end
