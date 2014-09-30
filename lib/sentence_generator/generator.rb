class SentenceGenerator::Generator
  def generate_sentences(options={})
    per_page = options.delete(:offset) || 10
    page     = options.delete(:page) || 1

    Sentence.paginate(per_page: per_page, page: page)
  end
end