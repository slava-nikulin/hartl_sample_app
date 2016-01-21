include ApplicationHelper

def sign_in(user, options={})
	if options[:no_capybara]
		post sessions_path email: user.email, password: user.password
	else
		visit signin_path
		fill_in "Email",    with: user.email
		fill_in "Password", with: user.password
		check "Remember me"
		click_button "Sign in"
	end
end

def sign_up(user, options={})
	if options[:no_capybara]
		post users_path, user: { name:  user.name,
			email: user.email,
			password:              user.password,
			password_confirmation: user.password }
		end
	else
		visit signup_path
		fill_in "Name",         with: user.name
		fill_in "Email",        with: user.email
		fill_in "Password",     with: user.password
		fill_in "Confirm Password", with: user.password
		click_button "Create my account" 
	end

	RSpec::Matchers.define :have_error_message do |message|
		match do |page|
			expect(page).to have_selector('div.alert.alert-danger', text: message)
		end
	end


