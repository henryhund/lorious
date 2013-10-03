class SocialMedium < ActiveRecord::Base
  belongs_to :user

  def self.available_media
    {
      "facebook" => "facebook"
    }
  end
end
