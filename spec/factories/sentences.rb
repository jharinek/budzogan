# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sentence do
    association :task

    content "MyString"
  end
end
