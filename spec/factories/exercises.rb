FactoryGirl.define do
  factory :exercise do
    association :template, factory: :exercise_template
    association :workgroup

    sentence_length 10
    sentence_difficulty :simple
    sentence_source :custom

    trait 'with_simple_sentences' do
      sentence_difficulty :simple
    end

    trait 'with_medium_sentences' do
      sentence_difficulty :medium
    end

    trait 'with_difficult_sentences' do
      sentence_difficulty :difficult
    end
  end
end
