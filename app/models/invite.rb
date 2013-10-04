class Invite < ActiveRecord::Base

  validates :name, :email, presence: true
  validates_format_of :name, 
          :with => /\A[a-zA-Z\s]+\z/ix,
          :message => "only letters allowed"
  validates_format_of :email,
          :with => /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/ix,
          :message => "invalid email address"

  include Tokenable

  after_save do
    if approved_changed? && approved
      UserMailer.invite_approved(self).deliver
    end
  end
end
