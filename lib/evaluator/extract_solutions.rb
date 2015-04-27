require 'awesome_print'
require 'nokogiri'
require 'pry'


raw_sentences = ARGV[0]
# def process_solutions(raw_sentences)
sentences_chopped = {}

File.open(raw_sentences).each_line do |line|
  content = line.split('|')[0]
  source = line.split('|')[1].strip

  unless ['dennikN', 'slovencina-8-rocnik'].member? source

    file_words = source

    file_structure = file_words.gsub(/\.w\z/, '.a')
    doc_words = Nokogiri::XML(File.open(file_words))
    blacklist = ['Atv', 'AtvV', 'Coord', 'Apos', 'AuxT', 'AuxR', 'AuxP', 'AuxC', 'AuxO', 'AuxZ', 'AuxX', 'AuxG', 'AuxY', 'AuxS', 'AuxK', 'ExD', 'AtrAtr', 'AtrAdv', 'AdvAtr', 'AtrObj', 'ObjAtr']
    sentences = Hash.new

    Nokogiri::XML(File.open(file_structure)).css('trees>LM').each do |node|
      node_id = node[:id].gsub(/\Aa\-/, '')

      sentences[node_id] = {}
      i = node_id.split('-').last.gsub(/p\d*s/, '').to_i - 1
      sentences[node_id][:sentence] = doc_words.search("w[id=\"#{ 'w-' + node_id + 'w1' }\"]").first.ancestors('para').first.text.split(/\.|\!|\?/)[i] #.gsub(/\s/, ' ').strip
      sentences[node_id][:sentence] = sentences[node_id][:sentence].gsub(/\s/, ' ').strip.gsub(/ ,/, ',') if sentences[node_id][:sentence]

      if sentences[node_id][:sentence].include? content[0..-2]
        sentences_chopped[content] = {}

        node.css('LM').each do |element|
          element_id = element[:id].gsub(/\Aa\-/, '')

          afun = (element.elements.find { |e| e.name == 'afun' }).text
          key = doc_words.search("w[id=\"#{'w-' + element_id}\"]").text
          parent = doc_words.search("w[id=\"#{ 'w-' + element.ancestors('LM').first[:id].gsub(/\Aa\-/, '') }\"]").text

          sentences_chopped[content][key] = {}
          sentences_chopped[content][key][:element] = afun
          sentences_chopped[content][key][:parent] = parent
        end
      end
    end
  end
end

f = File.open('output', 'w')
f.write(sentences_chopped.inspect)
# end


# ------------------------------------
# structure_files = ARGV
# sentences       = Hash.new

# structure_files.each do |file_structure|
#   file_words = file_structure.gsub(/\.a\z/, '.w')
#   doc_words = Nokogiri::XML(File.open(file_words))
#
#   blacklist = ['Atv', 'AtvV', 'Coord', 'Apos', 'AuxT', 'AuxR', 'AuxP', 'AuxC', 'AuxO', 'AuxZ', 'AuxX', 'AuxG', 'AuxY', 'AuxS', 'AuxK', 'ExD', 'AtrAtr', 'AtrAdv', 'AdvAtr', 'AtrObj', 'ObjAtr']
#
#   file_identifier = file_structure.split('/').last.gsub(/\.a\z/, '')
#
#   sentences[file_identifier] = {}
#
#   Nokogiri::XML(File.open(file_structure)).css('trees>LM').each do |node|
#     node_id = node[:id].gsub(/\Aa\-/, '')
#
#     sentences[file_identifier][node_id] = {}
#     i = node_id.split('-').last.gsub(/p\d*s/, '').to_i - 1
#     sentences[file_identifier][node_id][:sentence] = doc_words.search("w[id=\"#{ 'w-' + node_id + 'w1' }\"]").first.ancestors('para').first.text.split('.')[i] #.gsub(/\s/, ' ').strip
#     sentences[file_identifier][node_id][:sentence].gsub!(/\s/, ' ').strip!.gsub!(/ ,/, ',') if sentences[file_identifier][node_id][:sentence]
#
#
#     node.css('LM').each do |element|
#       afun = (element.elements.find { |e| e.name == 'afun' }).text
#
#       # next if blacklist.member? afun
#
#       element_id = element[:id].gsub(/\Aa\-/, '')
#
#       sentences[file_identifier][node_id][element_id] = {}
#       sentences[file_identifier][node_id][element_id][:type] = afun
#       sentences[file_identifier][node_id][element_id][:parent_id] = element.ancestors('LM').first[:id].gsub(/\Aa\-/, '')
#       sentences[file_identifier][node_id][element_id][:word] = doc_words.search("w[id=\"#{'w-' + element_id}\"]").text
#     end
#   end
# end
#
# ap sentences