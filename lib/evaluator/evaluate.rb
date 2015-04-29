require 'json'
require 'pry'
require_relative './processed_task.rb'
require_relative './token.rb'
require_relative './relation.rb'

def process_task(task)
  solution = JSON.parse task.student_solution.to_json
  links    = []
  nodes    = []

  processed_task = ProcessedTask.new(task.sentence, task)

  solution["cells"].each do |cell|
    cell["type"] == "link" ? links << cell : nodes << cell
  end

  ids_hash        = {}

  sentence = task.sentence
  words    = sentence.content.split ' '

  words.each { |w| processed_task.tokens << Token.new(w) }

# process nodes
  nodes.each_with_index do |node, i|
    properties     = node["attrs"]["rect"]["class"].split
    properties.delete 'properties'

    ids_hash[node["id"].to_sym] = []
    node_text = node["attrs"]["text"]["text"].strip.gsub(/\b[a-zA-Z][a-zA-Z]\b | \b[a-zA-Z][a-zA-Z]\b| \b[a-zA-z]\b|\b[a-zA-z]\b /, '')

    node_text.split(' ').each do |part|
      part.gsub!('.', '')
      part.gsub!('!', '')
      part.gsub!('?', '')
      part.gsub!(',', '')
      part.gsub!(';', '')

      ids_hash[node["id"].to_sym] << part
      i = processed_task.tokens.index { |t| t.text == part }

      processed_task.tokens[i].properties[0] = properties[0].to_i
      processed_task.tokens[i].properties[1] = properties[1].to_i
      processed_task.tokens[i].properties[2] = properties[2].to_i
    end
  end

# process links
  links.each do |link|
    processed_link = {}

    source = link["source"]["id"]
    target = link["target"]["id"]

    type = link["labels"][0]["attrs"]["text"]["text"].strip

    if source && target
      src = ids_hash[link["source"]["id"].to_sym].first
      tgt = ids_hash[link["target"]["id"].to_sym].first

      processed_task.relations << Relation.new(src, tgt, type)

      ids_hash[link["source"]["id"].to_sym].each_with_index do |el, i|
        if ids_hash[link["source"]["id"].to_sym][i+1]
          src = ids_hash[link["source"]["id"].to_sym][i]
          tgt = ids_hash[link["source"]["id"].to_sym][i+1]
          processed_task.relations << Relation.new(src, tgt, :compound)
        end
      end

      ids_hash[link["target"]["id"].to_sym].each_with_index do |el, i|
        if ids_hash[link["target"]["id"].to_sym][i+1]
          src = ids_hash[link["target"]["id"].to_sym][i]
          tgt = ids_hash[link["target"]["id"].to_sym][i+1]
          processed_task.relations << Relation.new(src, tgt, :compound)
        end
      end
    end
  end

  processed_task
end

def initialize_data_array
  data_array = Hash.new
  Sentence.all.each do |s|
    data_array[s.id] = Hash.new
    data_array[s.id][:student_solutions]  = []
    data_array[s.id][:extracted_solution] = nil
    data_array[s.id][:correct_solution]   = nil
    data_array[s.id][:statistics]         = {}
  end

  data_array
end

def resolve_word_index(sentence, word)
  (i=sentence.index word) ? i + 1 : 0
end

def process_all_tasks
  tasks = Task.started
  processed_data = initialize_data_array

  tasks.each do |task|
    puts "id: #{task.sentence_id.to_s}"
    processed_data[task.sentence_id][:student_solutions] << process_task(task)
  end

  processed_data
end

def summarize_data(data)
  processed_data = data

  processed_data.each do |key , sentence_data|
    sentence_data[:extracted_solution] = ProcessedTask.new(sentence_data[:student_solutions].first.sentence, nil)
    sentence_data[:extracted_solution].sentence.content.split(' ').each { |word| sentence_data[:extracted_solution].tokens << Token.new(word) }
    summarized_data = {}
    sentence_data[:extracted_solution].tokens.each {|token| summarized_data[token.text] = [Array.new(6,0), Array.new(7,0), Array.new(6,0)] }

    if sentence_data
      sentence_data[:student_solutions].each do |sample|
        sample.tokens.each do |token|
          summarized_data[token.text][0][token.properties[0]] += 1
          summarized_data[token.text][1][token.properties[1]] += 1
          summarized_data[token.text][2][token.properties[2]] += 1
        end
      end

      summarized_data.each do |key, value|
        i = sentence_data[:extracted_solution].tokens.index {|t| t.text == key}
        sentence_data[:extracted_solution].tokens[i].properties = evaluate_properties(value, sentence_data[:student_solutions].count, 0.7)
        end
    end
  end
end

def evaluate_properties(properties, samples_count, treshold)
  result = []

  properties.each_with_index do |property, i|
    property.map! { |p| Float(p)/Float(samples_count) }

    candidate = property.each_with_index.max

    if candidate[0] >= treshold
      result[i] = candidate[1]
    else
      # TODO co ak sa daco pokasle? - detekcia chyby
      result[i] = 0
    end
  end

  result
end

def evaluate_property(property_array, samples_count)
  out = ''
  array = []

  property_array.each_with_index do |el, i|
    next if el == 0
    tmp = []
    tmp[0] = i
    tmp[1] = el
    array << tmp
  end

  array.sort! { |a, b| b[1] <=> a[1]}

  array.each { |el| out += "#{el[0]}->#{el[1]}(#{(Float(el[1])/Float(samples_count)*100).round(3)}%);"}

  out
end

def evaluate_connections(connections, samples_count)
  out = ''
  array= []

  connections.each do |key, value|
    tmp = []
    tmp[0] = key
    tmp[1] = value
    array << tmp
  end

  array.sort! { |a, b| b[1] <=> a[1] }

  array.each { |a| out += "#{a[0]}:#{a[1]}(#{(Float(a[1])/Float(samples_count)*100).round(3)}%)"}

  out
end

def extract_corpus_solutions(data)

  sentences_chopped = {}

  Sentence.find_each do |sentence|
    content = sentence.content
    source  = sentence.source.gsub(/\.\z/, '')

    unless ['dennikN', 'slovencina-8-rocnik'].member? source
      data[sentence.id][:correct_solution] = ProcessedTask.new(sentence, nil)

      content.split(' ').each { |w| data[sentence.id][:correct_solution].tokens << Token.new(w) }

      file_words = source.gsub('/media/jozef/Novýsvazek/Dokumenty/FIIT/ing/diplomova_praca', '/home/jozef/tmp')

      file_structure = file_words.gsub(/\.w\z/, '.a')
      doc_words = Nokogiri::XML(File.open(file_words))
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

            key.gsub!('.', '')
            key.gsub!('!', '')
            key.gsub!('?', '')
            key.gsub!(',', '')
            key.gsub!(';', '')

            index = data[sentence.id][:correct_solution].tokens.index { |t| t.text == key }

            if index
              data[sentence.id][:correct_solution].tokens[index].properties[0] = resolve_property(afun)
              data[sentence.id][:correct_solution].relations << Relation.new(key, parent, resolve_relation)
            end
          end
        end
      end
    end
  end
end

def resolve_property(property)
  blacklist = ['Atv', 'AtvV', 'Coord', 'Apos', 'AuxT', 'AuxR', 'AuxP', 'AuxC', 'AuxO', 'AuxZ', 'AuxX', 'AuxG', 'AuxY', 'AuxS', 'AuxK', 'ExD', 'AtrAtr', 'AtrAdv', 'AdvAtr', 'AtrObj', 'ObjAtr']

  return 0 if blacklist.include? property

  case property
    when 'Pred' || 'Pnom' || 'AuxV'
      return 1
    when 'Sb'
      return 2
    when 'Obj'
      return 3
    when 'Atr'
      return 4
    when 'Adv'
      return 5
    else
      return -1
  end
end

def resolve_relation
  return 0
end

def evaluate_tokens(data)
  tokens_overall_positive = 0
  tokens_overall_negative = 0

  data.each do |key, sentence|
    next unless sentence[:correct_solution]

    tokens_positive = 0
    tokens_negative = 0
    sentence[:extracted_solution].tokens.each_with_index do |token, index|
      next if sentence[:correct_solution].tokens[index].properties[0] == 0 || token.properties[0] == 0

      if token.properties[0] == sentence[:correct_solution].tokens[index].properties[0]
        tokens_positive         += 1
        tokens_overall_positive += 1
      else
        tokens_negative         += 1
        tokens_overall_negative += 1
      end
    end

    sentence[:tokens_positive] = tokens_positive
    sentence[:tokens_negative] = tokens_negative
  end

  result = {}
  result[:tokens_negative] = tokens_overall_negative
  result[:tokens_positive] = tokens_overall_positive

  result
end

def print_data(data)
  data.each do |k,v|
    v[:extracted_solution].tokens.each {|t| puts "#{t.properties[0]} - #{t.properties[1]} - #{t.properties[2]}"}
  end

  1
end
