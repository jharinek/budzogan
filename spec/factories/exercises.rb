FactoryGirl.define do
  factory :exercise do
    association :template, factory: :exercise_template
    association :workgroup

    sentence_length 10
    sentence_difficulty :easy
    sentence_source :custom

    description 'Danú vetu nakreslite v syntaktickom strome'

    status :new

    trait 'with_simple_sentences' do
      sentence_difficulty :easy
    end

    trait 'with_medium_sentences' do
      sentence_difficulty :medium
    end

    trait 'with_hard_sentences' do
      sentence_difficulty :hard
    end
  end
end
