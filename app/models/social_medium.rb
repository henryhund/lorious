class SocialMedium < ActiveRecord::Base
  belongs_to :user

  validates :name, presence: true

  def self.available_media
    {
      "Facebook" => "facebook",
      "Twitter" => "twitter",
      "Linkedin" => "linkedin",
      "Github" => "github",
      "Stack Overflow" => "stackexchange"
    }
  end
end
