include ApplicationHelper

def sign_in(user, options={})
	if options[:no_capybara]
		remember_token = User.new_remember_token
		cookies[:remember_token] = remember_token
		user.update_attribute(:remember_token, User.encrypt(remember_token))
	else
		visit signin_path
		fill_in "Email",    with: user.email
		fill_in "Password", with: user.password
		click_button "Sign in"
	end
end

def signup(user)
	fill_in "Name",         with: user.name
	fill_in "Email",        with: user.email
	fill_in "Password",     with: user.password
	fill_in "Confirm Password", with: user.password
end

RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		expect(page).to have_selector('div.alert.alert-danger', text: message)
	end
end