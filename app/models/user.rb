class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  acts_as_taggable
  acts_as_taggable_on :skills

  attr_accessor :hourly_cost, :current_step

  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:google_oauth2, :facebook, :twitter, :github, :stackexchange, :linkedin]

  acts_as_messageable
  mount_uploader :image, ImageUploader

  has_many :reviews_made, class_name: "Review", foreign_key: "reviewer_id", dependent: :destroy
  has_many :reviews_received, class_name: "Review", foreign_key: "reviewed_id", dependent: :destroy

  has_many :requests_made, class_name: "Request", foreign_key: "requester_id", dependent: :destroy
  has_many :requests_received, class_name: "Request", foreign_key: "requested_id", dependent: :destroy

  has_many :transactions_made, class_name: "CreditTransaction", foreign_key: "transacter_id", dependent: :destroy
  has_many :transactions_received, class_name: "CreditTransaction", foreign_key: "transacted_id", dependent: :destroy

  has_many :appointments

  has_many :social_media, dependent: :destroy

  has_many :interests, dependent: :destroy
  accepts_nested_attributes_for :interests


  geocoded_by :location
  after_validation :geocode

  with_options if: :user_info_step_validation_required do |user|
    user.validates :username, uniqueness: true
    validates_format_of :username,
          :with => /\A\w+\z/ix,
          :message => "only letters and digits allowed, no spaces"
    user.validates :username, :first_name, :last_name, :tag_line, :location, presence: true
  end

  with_options if: :apply_for_expert_step_validation_required do |user|
    user.validates :job, presence: true
  end

  with_options if: :apply_for_expert_page? do |user|
    user.validates :stack_overflow_url, :github_url, :linked_in_url, :personal_website, :about_description, presence: true
  end

  with_options if: :profile_info_step_validation_required do |user|
    user.validates :bio, :job, presence: true
    user.validates :job, length: { in: 5..30 }
  end

  @disallowed_usernames = [
    "admin",
    "legal",
    "user",
    "careers",
    "subscriptions",
    "about",
    "help",
    "sidekiq",
    "control_panel",
    "contact"
  ]

  validates :username, :exclusion=> { :in => @disallowed_usernames }

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

      saved = user.save(validate: false) rescue false

      if saved
        user.social_media.create(name: "google_oauth2", profile: oauth_data.extra.raw_info.link, data: oauth_data.to_json) if oauth_data.extra.raw_info.link
      end

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
    validation_required? "user_info" || (step_1_complete && step_2_complete)
  end

  def apply_for_expert_step_validation_required
    validation_required? "apply_for_expert"
  end

  def profile_info_step_validation_required
    validation_required? "profile_info" || (step_1_complete && step_2_complete)
  end

  def validation_required? step=nil
    current_step.nil? || current_step == step
  end

  def change_to_expert_and_return_user!
    self.type = "Expert"
    @expert = self.becomes(Expert)
    @expert.create_availability
    UserMailer.delay.new_expert_request(self)
  end

  def profile_info_page?
    current_step == "profile_info"
  end

  def apply_for_expert_page?
    current_step == "apply_for_expert"
  end

  def name
    "#{first_name.capitalize} #{last_name.first.capitalize}."
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

  def upcoming_appointment_count
    Appointment.upcoming.where("user_id = ? OR expert_id = ?", self.id, self.id).order(:created_at => :desc).size rescue 0
  end

  def pending_appointment_count
    Appointment.pending.where("user_id = ? OR expert_id = ?", self.id, self.id).order(:created_at => :desc).size rescue 0
  end


  def profile_link_for social_medium
    self.social_media.find_by_name(social_medium).try(:profile)
  end

  def expert?
    self.type == "Expert"
  end

  def user?
    self.type == "User"
  end

  def credits
    self.transactions_made.inject(0) { |sum, e| sum + e.amount_with_sign }
  end

  def verified?
    self.social_media.length > 3
  end

  before_save do
    if expert_approved_changed? && is_expert_applied && expert_approved
      self.change_to_expert_and_return_user!
    end
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end

end
