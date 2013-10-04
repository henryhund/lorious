class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2, :facebook, :twitter, :github, :stackexchange, :linkedin]

  acts_as_messageable
  mount_uploader :image, ImageUploader

  has_many :reviews_made, class_name: "Review", foreign_key: "reviewer_id"
  has_many :reviews_received, class_name: "Review", foreign_key: "reviewed_id"
  has_many :appointments
  has_many :social_media, dependent: :destroy

  validates :username, uniqueness: true, allow_blank: true
  validates_format_of :username, 
          :with => /\A\w+\z/ix,
          :message => "only letters and digits allowed, no spaces", allow_blank: true
  validates_format_of :website, 
          :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
          :message => "not a valid url", allow_blank: true

  def self.find_for_google_oauth2(access_token, oauth_params, signed_in_resource=nil)
    data = access_token.info
    if oauth_params["invite_token"] && invite = Invite.find_by_token(oauth_params["invite_token"])
      user = User.create(
         email: data["email"],
         password: Devise.friendly_token[0,20],
         first_name: data["first_name"],
         last_name: data["last_name"],
         remote_image_url: data["image"]
      )
    end
    user = User.where(:email => data["email"]).first || User.new
    user
  end

  def mailboxer_email(object)
    #Check if an email should be sent for that object
    #if true
    return email
    #if false
    #return nil
  end

  def update_social_media_for provider, link, data
    begin
      self.social_media.where(name: provider).first_or_create(profile: link, data: data.to_json)
    rescue Exception => e
      print e
      false
    else
      true
    end
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
