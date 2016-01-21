class UsersController < ApplicationController
	before_action :signed_in_user, only: [:edit, :update, :index, :destroy]
	before_action :correct_user,   only: [:edit, :update]
	before_action :admin_user,     only: :destroy
	before_action :no_access_for_signed_in, only: [:new, :create]

	def index
		@users = User.paginate(page: params[:page])
	end

	def show
		@user = User.find(params[:id])
	end
	
	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)  
		if @user.save
			@user.send_activation_email
			flash[:info] = "Please check your email to activate your account."
			redirect_to root_url
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @user.update_attributes(user_params)
			flash[:success] = "Profile updated"
			redirect_to @user
		else
			render 'edit'
		end
	end

	def destroy
		user = User.find(params[:id])
		unless current_user?(user)
			user.destroy 
			flash[:success] = "User deleted."
			redirect_to users_url
		end
	end

	private

	def user_params
		params.require(:user).permit(:name, :email, :password, 
			:password_confirmation)
	end

	# Before filters

	def signed_in_user
		unless signed_in?
			store_location
			redirect_to signin_url, danger: "Please sign in."
		end
	end

	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_url) unless current_user?(@user)
	end

	def admin_user
		redirect_to(root_url) unless current_user.admin?
	end

	def no_access_for_signed_in
		redirect_to(root_url) if signed_in?
	end
end
