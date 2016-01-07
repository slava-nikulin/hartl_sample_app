require 'rails_helper'
include ApplicationHelper

describe "Static pages" do

	subject { page }

	shared_examples_for "all static pages" do
		it { is_expected.to have_selector('h1', text: heading) }
		it { is_expected.to have_title(full_title(page_title)) }
	end

	describe "Home page" do
		before { visit root_path }

		let(:heading)    { 'Sample App' }
		let(:page_title) { '' }
		it_should_behave_like "all static pages"

		it { is_expected.not_to have_title('| Home') }
	end

	describe "Help page" do
		before { visit help_path }

		let(:heading)    { 'Help' }
		let(:page_title) { 'Help' }
		it_should_behave_like "all static pages"	
	end

	describe "About page" do
		before { visit about_path }

		let(:heading)    { 'About Us' }
		let(:page_title) { 'About Us' }
		it_should_behave_like "all static pages"	
	end

	describe "Contact page" do
		before { visit contact_path }

		let(:heading)    { 'Contact' }
		let(:page_title) { 'Contact' }
		it_should_behave_like "all static pages"	
	end

	describe "Contact page" do
		before { visit contact_path }

		let(:heading)    { 'Contact' }
		let(:page_title) { 'Contact' }
		it_should_behave_like "all static pages"	
	end

	describe "hhh" do
		before { visit root_path }
		
		it { 
			click_link("About", :match => :first)
			is_expected.to have_title(full_title('About Us')) 
			click_link "Help"
			is_expected.to have_title(full_title('Help')) 
			click_link "Contact"
			is_expected.to have_title(full_title('Contact')) 
			click_link "Home"
			is_expected.not_to have_title(full_title('| Home')) 
			click_link "Sign up now!"
			is_expected.to have_title(full_title('Sign up')) 
			click_link "sample app"
			is_expected.not_to have_title(full_title('| Home')) 
		}
	end
end