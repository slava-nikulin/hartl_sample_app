class User < ActiveRecord::Base
	has_secure_password
	before_save { self.email.downcase! }
	before_create :create_remember_digest, :create_activation_digest
	attr_accessor :activation_token, :reset_token

	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, 
	uniqueness: { case_sensitive: false }
	validates :password, length: { minimum: 6 }
	has_many :microposts, dependent: :destroy

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_columns(reset_digest: User.encrypt(reset_token), reset_sent_at: Time.zone.now)
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def activate
		update_columns(activated: true, activated_at: Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		digest == User.encrypt(token)
	end

	def feed
    	Micropost.where("user_id = ?", id)
  	end

	private

	def create_remember_digest
		self.remember_digest = User.encrypt(User.new_token)
	end

	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.encrypt(self.activation_token)
	end
end
