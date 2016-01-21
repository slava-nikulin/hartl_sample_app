class User < ActiveRecord::Base
	has_secure_password
	before_save { self.email.downcase! }
	before_create :create_remember_token, :create_activation_digest
	attr_accessor :activation_token

	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, 
	uniqueness: { case_sensitive: false }
	validates :password, length: { minimum: 6 }


	def activate
		update_attribute(:activated,    true)
		update_attribute(:activated_at, Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def activation_token_valid?(token)
		self.activation_digest == User.encrypt(token)
	end

	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	private

	def create_remember_token
		self.remember_token = User.encrypt(User.new_token)
	end

	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.encrypt(self.activation_token)
	end
end
