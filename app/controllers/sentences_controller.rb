class SentencesController < ApplicationController
  def generate
    @generator = SentenceGenerator::Generator.new
    @sentences = Sentence.all # @generator.generate_sentences()
  end
end