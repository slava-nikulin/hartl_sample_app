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
	has_many :active_relationships, class_name:  "Relationship",
	foreign_key: "follower_id",
	dependent:   :destroy
	has_many :followed_users, through: :active_relationships, source: :followed
	has_many :passive_relationships, class_name:  "Relationship",
	foreign_key: "followed_id",
	dependent:   :destroy
	has_many :followers, through: :passive_relationships

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
		following_ids = "SELECT followed_id FROM relationships
		WHERE  follower_id = :user_id"
		Micropost.where("user_id IN (#{following_ids})
			OR user_id = :user_id", user_id: id)
	end

	def following?(other_user)
		self.active_relationships.find_by(followed_id: other_user.id)
	end

	def follow!(other_user)
		self.active_relationships.create!(followed_id: other_user.id)
	end

	def unfollow!(other_user)
		self.active_relationships.find_by(followed_id: other_user.id).destroy!
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
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
