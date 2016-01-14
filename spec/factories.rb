FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
  end

  factory :new_user, class: User do
    name     "Example User"
    email    "user@example.com"
    password "foobar"
    password_confirmation "foobar"
  end

  factory :admin, class: User do
    admin true
    name     "Example Admin"
    email    "user@admin.com"
    password "foobar"
    password_confirmation "foobar"
  end
end