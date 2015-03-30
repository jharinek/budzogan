class Extractor
  def initialize(output_file)
    @target = File.open(output_file, 'a')
    @target.puts '------------------------------'
    @target.puts Time.now
    @target.puts '------------------------------'
  end

  def sentences_count(document)
    document.css('para').count
  end

  def extract_sentences(document, filename)
    document.css('para').each do |p|
      sentence = ''

      p.css('token').each { |token| sentence += token.text + ' ' }

      sentence.strip!
      sentence.gsub!(/ \./, '.')
      sentence.gsub!(/ \!/, '!')
      sentence.gsub!(/ \?/, '?')
      sentence.gsub!(/ \,/, ',')
      sentence.gsub!(/ \;/, ';')
      sentence.gsub!(/ \"/, '"')
      sentence.gsub!(/ \"/, '"')
      sentence.gsub!(/ \'/, '\'')

      sentence += '|'
      sentence += filename

      @target.puts sentence
    end
  end
end