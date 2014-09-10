FactoryGirl.define do
  factory :exercise do
    association :template, factory: :exercise_template
    association :workgroup

    status :new

    trait :in_setup_state do
      status :setup

      description 'Danú vetu nakreslite v syntaktickom strome'
    end

    trait :in_sentences_state do
      status :sentences

      description 'Danú vetu nakreslite v syntaktickom strome'

      sentence_length 10
      sentence_difficulty :easy
      sentence_source :custom
    end

    trait :in_assignment_state do
      status :assignment

      description 'Danú vetu nakreslite v syntaktickom strome'

      sentence_length 10
      sentence_difficulty :easy
      sentence_source :custom
    end

    trait :in_active_state do
      status :active

      description 'Danú vetu nakreslite v syntaktickom strome'

      sentence_length 10
      sentence_difficulty :easy
      sentence_source :custom
    end
  end
end
