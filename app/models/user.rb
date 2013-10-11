class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:google_oauth2, :facebook, :twitter, :github, :stackexchange, :linkedin]

  attr_accessor :current_step, :skills

  acts_as_messageable
  mount_uploader :image, ImageUploader

  has_many :reviews_made, class_name: "Review", foreign_key: "reviewer_id"
  has_many :reviews_received, class_name: "Review", foreign_key: "reviewed_id"
  has_many :appointments

  has_many :social_media, dependent: :destroy

  has_many :interests, dependent: :destroy
  accepts_nested_attributes_for :interests

  has_many :credit_transactions

  geocoded_by :location
  after_validation :geocode

  with_options if: :user_info_step_validation_required do |user|
    user.validates :username, uniqueness: true
    validates_format_of :username, 
          :with => /\A\w+\z/ix,
          :message => "only letters and digits allowed, no spaces"
    user.validates :username, :first_name, :last_name, :tag_line, :location, presence: true
  end

  with_options if: :profile_info_step_validation_required do |user|
    user.validates :bio, :job, presence: true
  end

  validates_format_of :website, 
          :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
          :message => "not a valid url", allow_blank: true

  def self.find_for_google_oauth2(oauth_data, oauth_params, signed_in_resource=nil)
    data = oauth_data.info
    if oauth_params["invite_token"] && invite = Invite.approved.find_by_token(oauth_params["invite_token"])
      user = User.new(
         email: data["email"],
         password: Devise.friendly_token[0,20],
         first_name: data["first_name"],
         last_name: data["last_name"],
         remote_image_url: data["image"]
      )
      user.save validate: false
      user.social_media.create(name: "google_oauth2", profile: oauth_data.extra.raw_info.link, data: oauth_data.to_json) if oauth_data.extra.raw_info.link
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

  def initialize_steps
    @current_step = steps.first
  end

  def steps
    %w[user_info profile_info apply_for_expert]
  end

  def user_info_step_validation_required
    validation_required? "user_info"
  end

  def profile_info_step_validation_required
    validation_required? "profile_info"
  end

  def validation_required? step=nil
    current_step.nil? || current_step == step
  end

  def change_to_expert_and_return_user!
    self.type = "Expert"
    self.save
    self.becomes(Expert)
  end

  def profile_info_page?
    current_step == "profile_info"
  end

  def apply_for_expert_page?
    current_step == "apply_for_expert"
  end

  def name
    "#{first_name} #{last_name}"
  end

  def social_links
    {
      facebook: profile_link_for("facebook"),
      twitter: profile_link_for("twitter"),
      linkedin: profile_link_for("linkedin"),
      stackexchange: profile_link_for("stackexchange"),
      github: profile_link_for("github"),
      google: profile_link_for("google_oauth2"),
      personal: website
    }
  end

  def profile_link_for social_medium
    self.social_media.find_by_name(social_medium).try(:profile)
  end

  def expert?
    self.type == "Expert"
  end

  def credits
    self.credit_transactions.inject(0) { |sum, e| sum + e.amount_with_sign }
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end
end
