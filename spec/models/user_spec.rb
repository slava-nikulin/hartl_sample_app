require 'rails_helper'

describe User do

	before do
		@user = User.new(name: "Example User", email: "user@example.com",
			password: "foobar", password_confirmation: "foobar")
	end

	subject { @user }

	it { is_expected.to respond_to(:name) }
	it { is_expected.to respond_to(:email) }
	it { is_expected.to respond_to(:password_digest) }
	it { is_expected.to respond_to(:password) }
	it { is_expected.to respond_to(:password_confirmation) }
	it { is_expected.to respond_to(:authenticate) }
	it { is_expected.to respond_to(:remember_digest) }
	it { should respond_to(:admin) }
	it { should respond_to(:microposts) }
	it { should respond_to(:feed) }
	it { should respond_to(:active_relationships) }
	it { should respond_to(:followed_users) }
	it { should respond_to(:following?) }
	it { should respond_to(:follow!) }
	it { should respond_to(:passive_relationships ) }
	it { should respond_to(:followers) }

	it { should be_valid }
	it { should_not be_admin }

	describe "following" do
		let(:other_user) { FactoryGirl.create(:user) }
		before do
			@user.save
			@user.follow!(other_user)
		end

		it { should be_following(other_user) }
		specify { @user.followed_users.should include(other_user) }

		describe "followed user" do
			specify{ other_user.followers.should include(@user) }
		end

		describe "and unfollowing" do
			before { @user.unfollow!(other_user) }

			it { should_not be_following(other_user) }
			specify { @user.followed_users.should_not include(other_user) }
		end
	end

	describe '#authenticated?' do
		it { should_not be_authenticated(:remember, '') }
	end

	describe "with admin attribute set to 'true'" do
		before do
			@user.save!
			@user.toggle!(:admin)
		end

		it { should be_admin }
	end

	describe "when name is not present" do
		before { @user.name = " " }
		it { is_expected.not_to be_valid }
	end

	describe "when email is not present" do
		before { @user.email = " " }
		it { is_expected.not_to be_valid }
	end

	describe "when name is too long" do
		before { @user.name = "a" * 51 }
		it { is_expected.not_to be_valid }
	end

	describe "when email format is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.org example.user@foo.
				foo@bar_baz.com foo@bar+baz.com foo@bar..com]
				addresses.each do |invalid_address|
					@user.email = invalid_address
					expect(@user).not_to be_valid
				end
			end
		end

		describe "when email format is valid" do
			it "should be valid" do
				addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
				addresses.each do |valid_address|
					@user.email = valid_address
					expect(@user).to be_valid
				end
			end
		end

		describe "when email address is already taken" do
			before do
				user_with_same_email = @user.dup
				user_with_same_email.email = @user.email.upcase
				user_with_same_email.save
			end

			it { is_expected.not_to be_valid }
		end

		describe "when password is not present" do
			before { @user.password = @user.password_confirmation = " " }
			it { is_expected.not_to be_valid }
		end

		describe "when password doesn't match confirmation" do
			before { @user.password_confirmation = "mismatch" }
			it { is_expected.not_to be_valid }
		end

		describe "with a password that's too short" do
			before { @user.password = @user.password_confirmation = "a" * 5 }
			it { is_expected.to be_invalid }
		end

		describe "return value of authenticate method" do
			before { @user.save }
			let(:found_user) { User.find_by(email: @user.email) }

			describe "with valid password" do
				it { is_expected.to eq found_user.authenticate(@user.password) }
			end

			describe "with invalid password" do
				let(:user_for_invalid_password) { 
					found_user.authenticate("invalid") 
				}

				it { is_expected.not_to eq user_for_invalid_password }

				specify { expect(user_for_invalid_password).to be_falsey}
			end
		end

		describe "email address with mixed case" do
			let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

			it "should be saved as all lower-case" do
				@user.email = mixed_case_email
				@user.save
				expect(@user.reload.email).to eq mixed_case_email.downcase
			end
		end

		describe "remember token" do
			before { @user.save }
			let(:remember_digest){ @user.remember_digest}
			it "should not be empty" do
				expect(remember_digest).not_to be_empty
			end
		end

		describe "micropost associations" do

			before { @user.save }
			let!(:older_micropost) do
				FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
			end
			let!(:newer_micropost) do
				FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
			end

			it "should have the right microposts in the right order" do
				expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
			end

			it "should destroy associated microposts" do
				microposts = @user.microposts.to_a
				@user.destroy
				expect(microposts).not_to be_empty
				microposts.each do |micropost|
					expect(Micropost.where(id: micropost.id)).to be_empty
				end
			end

			describe "status" do
				subject { @user.feed.pluck(:id) }
				let(:unfollowed_post) { FactoryGirl.create(:micropost, user: FactoryGirl.create(:user)) }
				let(:followed_user) { FactoryGirl.create(:user) }

				before do
					@user.follow!(followed_user)
					3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
				end

				it { is_expected.to include(newer_micropost.id) }
				it { is_expected.to include(older_micropost.id) }
				it { is_expected.to_not include(unfollowed_post.id) }

				it { is_expected.to include(*followed_user.microposts.pluck(:id)) }
			end
		end

		describe "relationships associations" do
			let!(:user1) { FactoryGirl.create(:user) }
			let!(:user2) { FactoryGirl.create(:user) }
			before do 
				@user.save 
				user1.follow!(@user)
				@user.follow!(user2)
			end

			it "should destroy associated relationships" do
				@user.destroy
				expect(user1.followed_users).to be_empty
				expect(user2.followers).to be_empty
			end
		end
	end