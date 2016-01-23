require 'rails_helper'

describe "PasswordResets" do
	subject { page }

	let(:forgetful_user) { FactoryGirl.create(:user) }
	before { ActionMailer::Base.deliveries.clear }

	describe "post /password_resets_path" do 
		describe "with invalid email" do
			before {
				visit new_password_reset_path
				fill_in "Email", with: ""
				click_button "Submit" 
			}
			it {should have_error_message("Email address not found")}
		end

		describe "with valid email" do
			before {
				visit new_password_reset_path
				fill_in "Email", with: forgetful_user.email
				click_button "Submit" 
			}
			it { forgetful_user.reset_digest.should_not be eq(forgetful_user.reload.reset_digest) }
			it { ActionMailer::Base.deliveries.size.should eq(1)}
			it { is_expected.to have_selector('div.alert.alert-info') }
			it "should redirect to some other page" do
				expect(page.current_url).to eq root_url
			end
		end	

		describe "with expired token" do 
			before do
				post password_resets_path, email: forgetful_user.email
				user = assigns(:user)
				user.update_attribute(:reset_sent_at, 3.hours.ago)
				patch password_reset_path(user.reset_token),
				email: user.email,
				user: { password:              "foobar",
					password_confirmation: "foobar" }
			end

			specify { expect(response).to redirect_to new_password_reset_url }
		end
	end

	describe "reset form" do
		before { 
			post password_resets_path, { email: forgetful_user.email }
			@user = assigns(:user)
		}

		describe "get password reset form" do 
			describe "with wrong password" do
				before { get password_resets_edit_path(@user.reset_token, email: "") }
				specify { expect(response).to redirect_to root_url }
			end

			describe "with get password form with inactive user" do
				before {
					@user.toggle!(:activated)
					get password_resets_edit_path(@user.reset_token, email: @user.email)
				}
				specify { expect(response).to redirect_to root_url }
				after {@user.toggle!(:activated)}
			end

			describe "with correct email, wrong token" do
				before { get password_resets_edit_path('wrong token', email: @user.email)	}
				specify { expect(response).to redirect_to root_url }
			end

			describe "with correct email, correct token" do
				before { get edit_password_reset_path(@user.reset_token, email: @user.email) }
				specify { expect(response.body).to match(full_title('Reset password')) }
				specify { expect(response.body).to have_tag('input', :with => { :type => 'hidden', :value => @user.email }) }
			end
		end

		describe "post password reset form" do
			describe "with invalid password & confirmation" do
				before { 	patch password_reset_path(@user.reset_token),
					email: @user.email,
					user: { password:              "foobaz",
						password_confirmation: "barquux" 
					}
				}
				specify { expect(response.body).to have_tag('div', with: { :class => "alert alert-danger" }) }
			end
			describe "with empty password" do
				before { 	patch password_reset_path(@user.reset_token),
					email: @user.email,
					user: { 
						password:              "",
						password_confirmation: "" 
					}
				}
				specify { expect(response.body).to have_tag('div', with: { :class => "alert alert-danger" }) }
			end
			describe "with valid password & confirmation" do
				before { 
					visit edit_password_reset_path(@user.reset_token, email: @user.email)
					fill_in "Password", 		with: "foobaz"
					fill_in	"Confirmation" , 	with: "foobaz"
					click_button "Update password"
				}
				specify { expect(page.current_url).to eq user_url(@user) }
				it { should have_link "Sign out" }
			end
		end
	end	
end
