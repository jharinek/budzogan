FactoryGirl.define do
  factory :user, aliases: [:student] do
    sequence(:login) { |n| "user_#{n}" }
    sequence(:email) { |n| "user_#{n}@mailer.com" }

    password 'password'
    password_confirmation 'password'

    first 'Joe'
    last  'Doe'

    # TODO change according to roles model
    role :student

    factory :teacher, class: User do
      role :teacher
    end

    after :create do |user|
      user.confirm!
    end
  end
end
