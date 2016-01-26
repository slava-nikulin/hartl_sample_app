module SessionsHelper
	def sign_in(user, remember_me)
		remember_token = User.new_token
		if remember_me == '1'
			cookies.permanent.signed[:remember_token] = remember_token
		elsif
			cookies.signed[:remember_token] = remember_token
		end
		user.update_attribute(:remember_digest, User.encrypt(remember_token))
		self.current_user = user
		session[:a] = "123"
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		remember_token = User.encrypt(cookies.signed[:remember_token])
		@current_user ||= User.find_by(remember_digest: remember_token)
	end

	def signed_in?
		!current_user.nil?
	end

	def sign_out
		current_user.update_attribute(:remember_digest, User.encrypt(User.new_token))
		cookies.delete(:remember_token)
		self.current_user = nil
	end
	
	def current_user?(user)
		user == current_user
	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url if request.get?
	end

	def signed_in_user
		unless signed_in?
			store_location
			redirect_to signin_url, danger: "Please sign in."
		end
	end
end
