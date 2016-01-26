require 'rails_helper'
include ApplicationHelper

describe "User pages" do

	subject { page }

	describe "show" do
		let(:user) { FactoryGirl.create(:user) }

		describe "with inactivated user" do
			before {
				user.update_attribute(:activated, false)
				get user_path(user)
			}
			specify { expect(response).to redirect_to root_path }
		end

		describe "with activated user" do
			before { visit user_path(user) }
			it { should have_title(full_title(user.name)) }
		end
	end


	describe "index" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			sign_in user
			visit users_path
		end

		it { should have_title('All users') }
		it { should have_content('All users') }

		describe "activated user list" do
			before(:all) { 30.times { FactoryGirl.create(:user) }
			User.last.update_attribute(:activated, false) }
			after(:all)  { User.delete_all }

			it "should list each user" do
				User.paginate(page: 1).each do |user|
					if user.activated?
						expect(page).to have_selector('li', text: user.name)
					else
						expect(page).not_to have_selector('li', text: user.name)
					end
				end
			end
		end

		describe "pagination" do 
			before { 30.times { FactoryGirl.create(:user)}
			visit users_path
		}
		it { should have_selector('div.pagination') }
	end

	describe "delete links" do

		it { should_not have_link('delete') }

		describe "as an admin user" do
			let(:admin) { FactoryGirl.create(:admin) }
			before do
				sign_in admin
				visit users_path
			end

			it { should have_link('delete', href: user_path(User.first)) }
			it "should be able to delete another user" do
				expect do
					click_link('delete', match: :first)
				end.to change(User, :count).by(-1)
			end
			it { should_not have_link('delete', href: user_path(admin)) }
		end
	end

	it "should list each user" do
		User.all.each do |user|
			expect(page).to have_selector('li', text: user.name)
		end
	end
end

describe "sign_up page" do
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
		let(:new_user) { FactoryGirl.build(:user) }

		it "should create a user" do
			expect { sign_up(new_user) }.to change(User, :count).by(1)
		end

		describe "after saving the user" do
			before { sign_up new_user }
			it { should have_link('Sign in') }
			it { is_expected.to have_selector('div.alert.alert-info', text: 'activate your account') }
		end
	end

end

describe "profile page" do
	let(:user) { FactoryGirl.create(:user) }
	let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
	let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

	before { visit user_path(user) }

	it { is_expected.to have_content(user.name) }
	it { is_expected.to have_title(user.name) }

	describe "microposts" do
		it { should have_content(m1.content) }
		it { should have_content(m2.content) }
		it { should have_content(user.microposts.count) }
	end
end

describe "edit page" do
	let(:user) { FactoryGirl.create(:user) }
	before do
		sign_in user
		visit edit_user_path(user) 
	end

	describe "page" do
		it { should have_content("Update your profile") }
		it { should have_title("Edit user") }
		it { should have_link('change', href: 'http://gravatar.com/emails') }
	end

	describe "with invalid information" do
		before { click_button "Save changes" }
		it { should have_error_message('error') }
	end

	describe "with valid information" do
		let(:new_name)  { "New Name" }
		let(:new_email) { "new@example.com" }
		before do
			fill_in "Name",             with: new_name
			fill_in "Email",            with: new_email
			fill_in "Password",         with: user.password
			fill_in "Confirm Password", with: user.password
			click_button "Save changes"
		end

		it { should have_title(new_name) }
		it { should have_selector('div.alert.alert-success') }
		it { should have_link('Sign out', href: signout_path) }
		specify { expect(user.reload.name).to  eq new_name }
		specify { expect(user.reload.email).to eq new_email }
	end

	describe "forbidden attributes" do
		let(:params) do
			{ user: { admin: true, password: user.password,
				password_confirmation: user.password } }
			end
			before do
				sign_in user
				patch user_path(user), params
			end
			specify { expect(user.reload).not_to be_admin }
		end
	end
end