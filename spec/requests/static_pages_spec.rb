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

		describe "feed" do
			let(:user) { FactoryGirl.create(:user) }
			before do
				FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
				FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
				sign_in user
				visit root_path
			end
			describe "for signed-in users" do
				it "should render the user's feed" do
					user.feed.each do |item|
						expect(page).to have_selector("li#micropost-#{item.id}", text: item.content)
					end
				end

				it "should have 2 microposts" do
					expect(page).to have_content("#{user.microposts.count} microposts")
				end
			end

			describe "image upload" do
				let(:user) { FactoryGirl.create(:user) }
				before do
					fill_in "micropost_content",    with: "test"
					attach_file "micropost_picture", Rails.root + 'app/assets/images/test/rails.png'
					click_button "Post"
				end

				specify { user.reload.microposts.first.picture?.should be_truthy }
			end

			describe "micropost sidebar count" do
				it { should have_content "#{user.microposts.count} microposts"}

				it "should have correct label with 1 micropost" do
					user.microposts.first.destroy
					visit root_path
					expect(page).to have_content "#{user.microposts.count} micropost"
				end
			end

			describe "micropost pagination" do 
				before do
					50.times do |i|
						user.microposts.build(content: "micropost_#{i}").save
					end
					sign_in user
					visit root_path
				end

				it {should have_selector("ul.pagination li a", text: 2) }
			end

			describe "delete links" do 
				let(:another_user) { FactoryGirl.create(:user) }
				before do
					another_user.microposts.build(content: "another user micropost").save
					visit root_path
				end
				it {should_not have_link("delete", :href=>micropost_path(another_user.microposts.first.id))}
			end
		end
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

	describe "links behaviour" do
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