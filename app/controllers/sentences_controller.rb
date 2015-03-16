class SentencesController < ApplicationController
  def generate
    @generator = SentenceGenerator::Generator.new
    @sentences = Sentence.limit(10) # @generator.generate_sentences()
  end

  def create
    @sentence = Sentence.new(sentence_params)
    @sentence.save!
  end

  private

  def sentence_params
    params.require(:sentence).permit(:content, :source)
  end
end
