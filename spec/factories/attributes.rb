# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attribute, :class => 'Attribute' do
    name "MyString"
  end
end
