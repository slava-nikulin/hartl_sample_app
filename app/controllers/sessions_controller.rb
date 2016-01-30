class SessionsController < ApplicationController
	def new

	end

	def create
		#byebug
		user = User.find_by(email: params[:email].downcase)
		if user && user.authenticate(params[:password])
			if user.activated?
				sign_in(user, params[:remember_me])
				redirect_back_or user
			else
				message  = "Account not activated. "
				message += "Check your email for the activation link."
				flash[:warning] = message
				redirect_to root_url
			end
		else
			flash.now[:danger] = 'Invalid email/password combination'
			render 'new'
		end
	end

	def destroy 
		sign_out if signed_in?
		redirect_to root_url
	end
end
