require 'spec_helper'

describe Exercise do
  it 'has a valid factory' do
    exercise = build :exercise
    expect(exercise).to be_valid

    exercise = build :exercise, :in_setup_state
    expect(exercise).to be_valid

    exercise = build :exercise, :in_sentences_state
    expect(exercise).to be_valid

    exercise = build :exercise, :in_assignment_state
    expect(exercise).to be_valid
  end

  it 'requires valid description' do
    exercise = build :exercise, :in_setup_state, description: ''
    expect(exercise).not_to be_valid

    exercise = build :exercise, :in_setup_state, description: 'Popis cvičenia'
    expect(exercise).to be_valid
  end

  it 'requires to set sentence_length' do
    exercise = build :exercise, :in_sentences_state, sentence_length: nil
    expect(exercise).not_to be_valid

    exercise = build :exercise, :in_sentences_state, sentence_length: 5
    expect(exercise).to be_valid
  end

  it 'requires sentence_length higher than zero' do
    exercise = build :exercise, :in_sentences_state, sentence_length: -1
    expect(exercise).not_to be_valid

    exercise = build :exercise, :in_sentences_state, sentence_length: 0
    expect(exercise).not_to be_valid

    exercise = build :exercise, :in_sentences_state, sentence_length: 1
    expect(exercise).to be_valid
  end

  it 'requires to set sentence_difficulty' do
    exercise = build :exercise, :in_sentences_state, sentence_difficulty: nil
    expect(exercise).not_to be_valid

    exercise = build :exercise, :in_sentences_state, sentence_difficulty: :easy
    expect(exercise).to be_valid
  end

  it 'requires valid value of sentence_difficulty' do
    easy_exercise   = build :exercise, :in_sentences_state, sentence_difficulty: :easy
    medium_exercise = build :exercise, :in_sentences_state, sentence_difficulty: :medium
    hard_exercise   = build :exercise, :in_sentences_state, sentence_difficulty: :hard

    another_exercise = build :exercise, :in_sentences_state, sentence_difficulty: :difficult

    expect(another_exercise).not_to be_valid

    expect(easy_exercise).to    be_valid
    expect(medium_exercise).to be_valid
    expect(hard_exercise).to   be_valid
  end

  it 'requires to have a status' do
    exercise = build :exercise, status: nil
    expect(exercise).not_to be_valid

    exercise = build :exercise, status: :new
    expect(exercise).to be_valid
  end

  it 'requires to have a valid status' do
    exercise_new        = build :exercise, status: :new
    exercise_setup      = build :exercise, :in_setup_state, status: :setup
    exercise_sentences  = build :exercise, :in_sentences_state, status: :sentences
    exercise_assignment = build :exercise, :in_assignment_state, status: :assignment
    exercise_active     = build :exercise, :in_active_state, status: :active

    exercise_invalid = build :exercise, status: :invalid
    expect(exercise_invalid).not_to be_valid

    expect(exercise_new).to be_valid
    expect(exercise_setup).to be_valid
    expect(exercise_sentences).to be_valid
    expect(exercise_assignment).to be_valid
    expect(exercise_active).to be_valid
  end

  describe '#active?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active?).to eql(false)

      exercise = build :exercise, :in_active_state, status: :active
      expect(exercise.active?).to eql(true)
    end
  end

  describe '#active_or_setup?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active_or_setup?).to eql(false)

      exercise = build :exercise, :in_active_state, status: :active
      expect(exercise.active_or_setup?).to eql(true)
    end

    it 'returns true if exercise is in setup step' do
      exercise = build :exercise, :in_sentences_state, status: :sentences
      expect(exercise.active_or_setup?).to eql(false)

      exercise = build :exercise, :in_setup_state, status: :setup
      expect(exercise.active_or_setup?).to eql(true)
    end
  end

  describe '#active_or_sentences?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active_or_sentences?).to eql(false)

      exercise = build :exercise, :in_active_state, status: :active
      expect(exercise.active_or_sentences?).to eql(true)
    end

    it 'returns true if exercise is in sentences step' do
      exercise = build :exercise, :in_assignment_state, status: :assignment
      expect(exercise.active_or_sentences?).to eql(false)

      exercise = build :exercise, :in_sentences_state, status: :sentences
      expect(exercise.active_or_sentences?).to eql(true)
    end
  end

  describe '#active_or_assignment?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active_or_assignment?).to eql(false)

      exercise = build :exercise, :in_active_state, status: :active
      expect(exercise.active_or_assignment?).to eql(true)
    end

    it 'returns true if exercise is in assignment step' do
      exercise = build :exercise, :in_sentences_state, status: :sentences
      expect(exercise.active_or_assignment?).to eql(false)

      exercise = build :exercise, :in_assignment_state, status: :assignment
      expect(exercise.active_or_assignment?).to eql(true)
    end
  end
end
