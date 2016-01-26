FactoryGirl.define do
  factory :user, class: User do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    activated true
    activated_at Time.zone.now
    activation_token = User.new_token
    activation_digest = User.encrypt(activation_token)
  end

  factory :admin, class: User do
    admin true
    name     "Example Admin"
    email    "user@admin.com"
    password "foobar"
    password_confirmation "foobar"
    activated true
    activated_at Time.zone.now
  end

  factory :micropost do
    content "Lorem ipsum"
    user
  end
end