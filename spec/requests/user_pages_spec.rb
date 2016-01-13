require 'rails_helper'
include ApplicationHelper

describe "User pages" do

	subject { page }

	describe "signup page" do
		before { visit signup_path }

		it { is_expected.to have_selector('h1','Sign up') }
		it { is_expected.to have_title(full_title('Sign up')) }

		let(:submit) { "Create my account" }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end
			describe "after submission" do
				before { click_button submit }

				it { is_expected.to have_title('Sign up') }
				it { should have_error_message('error') }
			end
		end

		describe "with valid information" do
			let(:new_user) { FactoryGirl.build(:new_user) }
			before { valid_signup(new_user)	}
				
				it "should create a user" do
					expect { click_button submit }.to change(User, :count).by(1)
				end

				describe "after saving the user" do
					before { click_button submit }

				it { is_expected.to have_title(new_user.name) }
				it { is_expected.to have_selector('div.alert.alert-success', text: 'Welcome') }
			end

			describe "after saving the user" do
				before { click_button submit }

				it { should have_link('Sign out') }
				it { should have_title(new_user.name) }
				it { should have_selector('div.alert.alert-success', text: 'Welcome') }
			end
		end

	end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { is_expected.to have_content(user.name) }
		it { is_expected.to have_title(user.name) }
	end


end