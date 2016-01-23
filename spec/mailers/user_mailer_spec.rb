require "rails_helper"

describe UserMailer, type: :mailer do
  describe "account_activation" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.account_activation(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Account activation")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_link("Activate", edit_account_activation_url(user.activation_token))
    end
  end

  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { 
      user.create_reset_digest
      UserMailer.password_reset(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Password reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_link("Reset password", edit_password_reset_url(user.activation_token))
    end
  end

end
