# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :task do
    sentence_id 1
    exercise_id 1
    teacher_solution ""
    student_solution ""
  end
end
