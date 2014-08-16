FactoryGirl.define do
  factory :task do
    association :exercise

    state 0

    trait :with_sentence do
      after :create do |task|
        create :sentence, task: task
      end
    end

    trait :in_progress do
      state 1
    end

    trait :solved do
      state 2
    end
  end
end
