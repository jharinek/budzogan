class SentencesController < ApplicationController
  def generate
    @generator = SentenceGenerator::Generator.new
    @sentences = Sentence.limit(10) # @generator.generate_sentences()
  end
end