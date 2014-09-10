require 'spec_helper'

describe Exercise do
  it 'has a valid factory' do
    exercise = build :exercise
    expect(exercise).to be_valid
  end

  it 'requires valid description' do
    exercise = build :exercise, description: ''
    expect(exercise).not_to be_valid

    exercise = build :exercise, description: 'Popis cvičenia'
    expect(exercise).to be_valid
  end

  it 'requires to set sentence_length' do
    exercise = build :exercise, sentence_length: nil
    expect(exercise).not_to be_valid

    exercise = build :exercise, sentence_length: 5
    expect(exercise).to be_valid
  end

  it 'requires sentence_length higher than zero' do
    exercise = build :exercise, sentence_length: -1
    expect(exercise).not_to be_valid

    exercise = build :exercise, sentence_length: 0
    expect(exercise).not_to be_valid

    exercise = build :exercise, sentence_length: 1
    expect(exercise).to be_valid
  end

  it 'requires to set sentence_difficulty' do
    exercise = build :exercise, sentence_difficulty: nil
    expect(exercise).not_to be_valid

    exercise = build :exercise, sentence_difficulty: :easy
    expect(exercise).to be_valid
  end

  it 'requires valid value of sentence_difficulty' do
    easy_exercise    = build :exercise, sentence_difficulty: :easy
    medium_exercise = build :exercise, sentence_difficulty: :medium
    hard_exercise   = build :exercise, sentence_difficulty: :hard

    another_exercise = build :exercise, sentence_difficulty: :difficult

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
    pending
  end

  describe '#active?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active?).to eql(false)

      exercise = build :exercise, status: :active
      expect(exercise.active?).to eql(true)
    end
  end

  describe '#active_or_setup?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active_or_setup?).to eql(false)

      exercise = build :exercise, status: :active
      expect(exercise.active_or_setup?).to eql(true)
    end

    it 'returns true if exercise is in setup step' do
      exercise = build :exercise, status: :sentences
      expect(exercise.active_or_setup?).to eql(false)

      exercise = build :exercise, status: :setup
      expect(exercise.active_or_setup?).to eql(true)
    end
  end

  describe '#active_or_sentences?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active_or_sentences?).to eql(false)

      exercise = build :exercise, status: :active
      expect(exercise.active_or_sentences?).to eql(true)
    end

    it 'returns true if exercise is in sentences step' do
      exercise = build :exercise, status: :assignment
      expect(exercise.active_or_sentences?).to eql(false)

      exercise = build :exercise, status: :sentences
      expect(exercise.active_or_sentences?).to eql(true)
    end
  end

  describe '#active_or_assignment?' do
    it 'returns true if exercise is active' do
      exercise = build :exercise, status: :new
      expect(exercise.active_or_assignment?).to eql(false)

      exercise = build :exercise, status: :active
      expect(exercise.active_or_assignment?).to eql(true)
    end

    it 'returns true if exercise is in assignment step' do
      exercise = build :exercise, status: :sentences
      expect(exercise.active_or_assignment?).to eql(false)

      exercise = build :exercise, status: :assignment
      expect(exercise.active_or_assignment?).to eql(true)
    end
  end
end
