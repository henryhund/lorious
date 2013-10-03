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
  has_many :social_media

  validates :username, uniqueness: true, allow_blank: true
  validates_format_of :username, 
          :with => /\A\w+\z/ix,
          :message => "only letters and digits allowed, no spaces", allow_blank: true
  validates_format_of :website, 
          :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
          :message => "not a valid url", allow_blank: true

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)

    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(
           email: data["email"],
           password: Devise.friendly_token[0,20],
           first_name: data["first_name"],
           last_name: data["last_name"],
           remote_image_url: data["image"]
          )
    end
    user
  end

  def mailboxer_email(object)
    #Check if an email should be sent for that object
    #if true
    return email
    #if false
    #return nil
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
