# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :workgroup do
    sequence(:name) { |n| "Workgroup ##{n}" }

    association :teacher

    trait :with_students do
      after :create do |workgroup|
        3.times do
          student = create :student
          Enrollment.create(workgroup_id: workgroup.id, student_id: student.id)
        end
      end
    end
  end
end
