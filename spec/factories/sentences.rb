FactoryGirl.define do
  factory :sentence do
    association :task

    content "MyString"
  end
end
