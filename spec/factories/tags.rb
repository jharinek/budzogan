# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag, :class => 'Tags' do
    name "MyString"
  end
end
