require 'rails_helper'

describe "account activation" do
	subject { page }
	
	let(:new_user) { FactoryGirl.build(:user) }
	before { 
		ActionMailer::Base.deliveries.clear
		sign_up new_user, no_capybara: true 
	}
	context "when account was not activated" do
		it { expect(ActionMailer::Base.deliveries.size).to eq(1)}
		it { assigns(:user).should_not be_activated }
	end

	describe "signing in" do
		before{ sign_in new_user}
		it { should have_link "Sign in" }
	end

	describe "With invalid activation token" do
		before{ visit edit_account_activation_path("invalid token")}
		it { should have_error_message('Invalid') }
	end

	describe "With valid activation token and invalid email" do
		before { visit edit_account_activation_path(assigns(:user).activation_token, email: 'wrong') }
		it { should have_error_message('Invalid') }
	end

	describe "With valid activation token and valid email" do
		let(:user) { assigns(:user) }
		before { get edit_account_activation_path(user.activation_token, email: user.email) }
		it { user.reload.should be_activated }
		specify { expect(response).to redirect_to(user) }
		specify { expect(response.body).not_to match("Sign out") }
	end
end