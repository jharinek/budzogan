class ComputeSentencesLength < ActiveRecord::Migration
  def change
    Sentence.find_each do |sentence|
      sentence.length = sentence.content.split(' ').count

      sentence.save!
    end
  end
end
