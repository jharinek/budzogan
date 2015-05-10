require 'json'
require 'pry'
require 'yaml'
require_relative './processed_task.rb'
require_relative './token.rb'
require_relative './relation.rb'


def transform_file(file)
  f = File.open('results.csv', 'a')
  hash = YAML.load(File.read(file))

  hash.each do |key, value|
    f.write(key)
    f.write(",,\n")

    value.each do |k, v|
      s = "#{k}, #{v[:t_precision]}, #{v[:t_recall]}\n"
      f.write s
    end
  end

  f.close
end

def process_task(task, options={})
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

    node_text.split(' ').sort.each do |part|
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

  coeficient = options[:coeficient] || 1
  processed_task.options[:coeficient] = coeficient

  processed_task
end

def initialize_data_array(sentences)
  data_array = Hash.new
  sentences.each do |s|
    data_array[s.id] = Hash.new
    data_array[s.id][:student_solutions]  = []
    data_array[s.id][:extracted_solution] = nil
    data_array[s.id][:correct_solution]   = nil
    data_array[s.id][:statistics]         = {}
    data_array[s.id][:positives_t]        = 0
    data_array[s.id][:positives_r]        = 0
  end

  data_array
end

# def resolve_word_index(sentence, word)
#   (i=sentence.index word) ? i + 1 : 0
# end
def resolve_coeficient(student)
  case student.evaluation.to_i
    when 1
      return 1.5
    when 2
      return 1.3
    when 3
      return 1
    when 4
      return 0.7
    when 5
      return 0.5
    else
      return 1
  end
end

def process_all_tasks(tasks, sentences, options={})
  processed_data = initialize_data_array(sentences)
  opt = {}

  tasks.each do |task|
    opt[:coeficient] = resolve_coeficient(task.user)  if(options[:with_evaluation_coeficient])

    processed_data[task.sentence_id][:student_solutions] << process_task(task, opt) if sentences.ids.include? task.sentence.id
  end

  processed_data
end

def summarize_data(data, options)
  processed_data = data

  processed_data.each do |key , sentence_data|
    next if sentence_data[:student_solutions].empty?

    sentence_data[:extracted_solution] = ProcessedTask.new(sentence_data[:student_solutions].first.sentence, nil)
    sentence_data[:extracted_solution].sentence.content.split(' ').each { |word| sentence_data[:extracted_solution].tokens << Token.new(word) }
    summarized_data = {}
    summarized_relations = []
    token_samples_count    = sentence_data[:student_solutions].count

    sentence_data[:extracted_solution].tokens.each {|token| summarized_data[token.text] = [Array.new(6,0), Array.new(7,0), Array.new(6,0)] }

    sentence_data[:student_solutions].each do |sample|
      sample.tokens.each do |token|
        summarized_data[token.text][0][token.properties[0]] += 1*sample.options[:coeficient]
        summarized_data[token.text][1][token.properties[1]] += 1*sample.options[:coeficient]
        summarized_data[token.text][2][token.properties[2]] += 1*sample.options[:coeficient]
      end

      sample.relations.each do |relation|
        rel = summarized_relations.find { |rel| rel[:relation].equals? relation } || (summarized_relations << {relation: relation, count: 0}).last
        rel[:count] += 1*sample.options[:coeficient]
      end
    end

    summarized_relations.each do |relation|
      sentence_data[:extracted_solution].relations << relation[:relation] if valid? relation, sentence_data[:student_solutions].count, options[:relation_treshold]
    end

    summarized_data.each do |key, value|
      i = sentence_data[:extracted_solution].tokens.index { |t| t.text == key }
      sentence_data[:extracted_solution].tokens[i].properties = evaluate_properties(value, token_samples_count, options[:token_treshold], options[:drop_zero] || false)
    end
  end

  nil
end

def valid?(relation_hash, count, treshold)
  return true if Float(relation_hash[:count])/count > treshold

  false
end

def evaluate_properties(properties, samples_count, treshold, drop_zero=false)
  result = []

  properties.each_with_index do |property, i|
    if drop_zero
      samples_count -= property[0]
      property[0] = 0
    end

    property.map! { |p| samples_count > 0 ? Float(p)/Float(samples_count) : 0 }

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

# def evaluate_property(property_array, samples_count)
#   out = ''
#   array = []
#
#   property_array.each_with_index do |el, i|
#     next if el == 0
#     tmp = []
#     tmp[0] = i
#     tmp[1] = el
#     array << tmp
#   end
#
#   array.sort! { |a, b| b[1] <=> a[1]}
#
#   array.each { |el| out += "#{el[0]}->#{el[1]}(#{(Float(el[1])/Float(samples_count)*100).round(3)}%);"}
#
#   out
# end

# def evaluate_connections(connections, samples_count)
#   out = ''
#   array= []
#
#   connections.each do |key, value|
#     tmp = []
#     tmp[0] = key
#     tmp[1] = value
#     array << tmp
#   end
#
#   array.sort! { |a, b| b[1] <=> a[1] }
#
#   array.each { |a| out += "#{a[0]}:#{a[1]}(#{(Float(a[1])/Float(samples_count)*100).round(3)}%)"}
#
#   out
# end

def extract_expert_solutions(data, allowed_tokens)
  expert = User.where(nick: :expert).first
  tasks = expert.tasks.where(state: 2)

  tasks.each do |task|
    if data[task.sentence.id]
      data[task.sentence.id][:correct_solution] = process_task task
      data[task.sentence.id][:positives_t]      = count_tokens(data[task.sentence.id][:correct_solution].tokens, allowed_tokens)
      data[task.sentence.id][:positives_r]      = data[task.sentence.id][:correct_solution].relations.count
    end
  end
end

def count_tokens(tokens, allowed_tokens)
  count = 0
  tokens.each { |t| count += 1 if (t.properties[0] != 0) && allowed_tokens.include?(t.properties[0]) }

  count
end

def extract_corpus_solutions(data, allowed_tokens)

  sentences_chopped = {}

  Sentence.find_each do |sentence|
    content = sentence.content
    source = sentence.source.gsub(/\.\z/, '')

    unless ['dennikN', 'slovencina-8-rocnik'].member?(source)
      if (data[sentence.id] != nil)

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

            data[sentence.id][:positives_t] = count_tokens(data[sentence.id][:correct_solution].tokens, allowed_tokens)
            data[sentence.id][:positives_r] = data[sentence.id][:correct_solution].relations.count
          end
        end
      end
    end
  end
end

def resolve_property(property)
  blacklist = ['Atv', 'AtvV', 'Coord', 'Apos', 'AuxT', 'AuxR', 'AuxP', 'AuxC', 'AuxO', 'AuxZ', 'AuxX', 'AuxG', 'AuxY', 'AuxS', 'AuxK', 'ExD', 'AtrAtr', 'AtrAdv', 'AdvAtr', 'AtrObj', 'ObjAtr']

  # return 0 if blacklist.include? property

  case property
    when 'Pred' || 'Pnom'
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
      return 0
  end
end

def resolve_relation
  return 0
end

def evaluate_tokens(data, options={})
  tokens_overall_positive  = 0
  tokens_overall_negative  = 0
  tokens_overall_undefined = 0
  positives_overall_t      = 0

  data.each do |key, sentence|
    next if sentence[:student_solutions].empty?
    next unless sentence[:correct_solution]

    tokens_positive = 0
    tokens_negative = 0
    tokens_undefined = 0
    positives_overall_t += sentence[:positives_t]

    sentence[:extracted_solution].tokens.each_with_index do |token, index|
      correct_token = sentence[:correct_solution].tokens.find { |t| t.text == token.text }
      next if correct_token.properties[0] == 0 || !(options[:tokens].include? correct_token.properties[0])# || token.properties[0] == 0 ...sentence[:correct_solution].tokens[index]

      if token.properties[0] == correct_token.properties[0]
        tokens_positive         += 1
        tokens_overall_positive += 1
      else
        if token.properties[0] == 0
          tokens_undefined         += 1
          tokens_overall_undefined += 1
        else
          # puts "#{token.text}:#{token.properties[0]} - #{sentence[:correct_solution].tokens[index].properties[0]} - #{sentence[:correct_solution].sentence.content}"
          tokens_negative         += 1
          tokens_overall_negative += 1
        end
      end
    end

    sentence[:tokens_positive]  = tokens_positive
    sentence[:tokens_negative]  = tokens_negative
    sentence[:tokens_undefined] = tokens_undefined
  end

  result = {}
  result[:tokens_negative]   = tokens_overall_negative
  result[:tokens_positive]   = tokens_overall_positive
  result[:tokens_undefined]  = tokens_overall_undefined
  result[:tokens_positives_overall] = positives_overall_t

  result
end

def evaluate_relations(data, options={})
  relations_overall_positive  = 0
  relations_overall_negative  = 0
  relations_overall_undefined = 0
  positives_overall_r         = 0
  rel_count                   = 0

  data.each do |key, sentence|
    next if sentence[:student_solutions].empty?
    next unless sentence[:correct_solution]

    relations_positive  = 0
    relations_negative  = 0
    relations_undefined = 0

    sentence[:extracted_solution].relations.each do |relation|
      if valid_relation?(sentence[:correct_solution].relations, relation)
        relations_positive         += 1
        relations_overall_positive += 1
      else
        relations_negative         += 1
        relations_overall_negative += 1
      end

      rel_count += 1
    end

    sentence[:relations_positive]  = relations_positive
    sentence[:relations_negative]  = relations_negative
    sentence[:relations_undefined] = relations_undefined
    sentence[:positives_r]         = sentence[:correct_solution].relations.count
    positives_overall_r += sentence[:positives_r]
  end

  result = {}
  result[:relations_negative]  = relations_overall_negative
  result[:relations_positive]  = relations_overall_positive
  result[:relations_undefined] = relations_overall_undefined
  result[:positives_r]         = positives_overall_r
  result[:rel_cnt]             = rel_count

  result
end

def valid_relation?(relations, relation)
  return true if relations.find { |rel| rel.equal_elements? relation }

  false
end

def print_data(data)
  data.each do |k,v|
    v[:extracted_solution].tokens.each {|t| puts "#{t.properties[0]} - #{t.properties[1]} - #{t.properties[2]}"}
  end

  nil
end

def process_batch(tasks, sentences, options={})
  # compulsory
  # :relation_treshold (float), :token_treshold (float)

  # optional
  # :with_evaluation_coeficient (bool), :drop_zero (bool), :tokens ([])

  # options[:relation_treshold] = 0.4
  # options[:token_treshold]    = 0.7
  # options[:drop_zero]         = true
  # options[:tokens]            = [1,2,3,4,5]
  # options[:with_evaluation_coeficient] = true

  result = {}
  data = process_all_tasks tasks, sentences
  summarize_data data, options
  extract_corpus_solutions data, options[:tokens]
  extract_expert_solutions data, options[:tokens]
  result[:tokens]    = evaluate_tokens data, options
  result[:relations] = evaluate_relations data
  result[:data]      = data

  result
end


def commands
  load './lib/evaluator/evaluate.rb'

  sentences = Sentence.short(1000).where("source = 'dennikN' OR source = 'slovencina-8-rocnik'")
  User.where(evaluation: "1", role: "student").each {|u| u.tasks.started.each {|t| tasks << t}}

end

def relations_experiment
  results = {}
  yaml_file = File.open('results_relations.yaml', 'a')

  tresholds = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]

  options = {}
  # options[:relation_treshold] = 0.2
  options[:drop_zero]         = true
  options[:tokens]            = [1,2,3,4,5]
  options[:with_evaluation_coeficient] = false
  options[:token_treshold]    = 0.5

  # sentences
  ids = [];Sentence.where("source = 'dennikN' or source= 'slovencina-8-rocnik'").each { |s| ids << s.id if s.tasks.started.count > 10 && s.tasks.started.count < 100 }
  sentences = Sentence.where('id in (?)', ids)

  sentences_s = sentences.short  100
  sentences_m = sentences.medium 100
  sentences_l = sentences.long   100

  tasks = Task.started

  # altogether - relation treshold change
  results[:relation_treshold] = {}
  tresholds.each do |t|
    options[:relation_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:relation_treshold][t] = {}

    results[:relation_treshold][t][:positive] = data[:relations][:relations_positive]
    results[:relation_treshold][t][:negative] = data[:relations][:relations_negative]
    results[:relation_treshold][t][:positives_all]= data[:relations][:positives_r]
  end

  results[:relation_treshold_s] = {}
  tresholds.each do |t|
    options[:relation_treshold] = t

    data = process_batch(tasks, sentences_s, options)
    results[:relation_treshold_s][t] = {}

    results[:relation_treshold_s][t][:positive] = data[:relations][:relations_positive]
    results[:relation_treshold_s][t][:negative] = data[:relations][:relations_negative]
    results[:relation_treshold_s][t][:positives_all]= data[:relations][:positives_r]
  end

  results[:relation_treshold_m] = {}
  tresholds.each do |t|
    options[:relation_treshold] = t

    data = process_batch(tasks, sentences_m, options)
    results[:relation_treshold_m][t] = {}

    results[:relation_treshold_m][t][:positive] = data[:relations][:relations_positive]
    results[:relation_treshold_m][t][:negative] = data[:relations][:relations_negative]
    results[:relation_treshold_m][t][:positives_all]= data[:relations][:positives_r]
  end

  results[:relation_treshold_l] = {}
  tresholds.each do |t|
    options[:relation_treshold] = t

    data = process_batch(tasks, sentences_l, options)
    results[:relation_treshold_l][t] = {}

    results[:relation_treshold_l][t][:positive] = data[:relations][:relations_positive]
    results[:relation_treshold_l][t][:negative] = data[:relations][:relations_negative]
    results[:relation_treshold_l][t][:positives_all]= data[:relations][:positives_r]
  end

  yaml_file.write results.to_yaml
  yaml_file.close

  nil
end

def experiment
  results = {}
  yaml_file = File.open('results.yaml', 'a')
  xml_file  = File.open('results.xml', 'a')

  tresholds = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]

  options = {}
  options[:relation_treshold] = 0.2
  options[:drop_zero]         = true
  options[:tokens]            = [1,2,3,4,5]
  options[:with_evaluation_coeficient] = false

  # sentences
  ids = [];Sentence.all.each { |s| ids << s.id if s.tasks.started.count > 10 && s.tasks.started.count < 100 }
  sentences = Sentence.where('id in (?)', ids)

  tasks = Task.started

  # altogether - token treshold change
  results[:token_treshold] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold][t] = {}
    results[:token_treshold][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold][t][:r_las]
    results[:token_treshold][t][:r_uas]
    results[:token_treshold][t][:r_la]
  end

  # altogether - token treshold change, with evaluation coeficient
  results[:token_treshold_evaluation_coeficient] = {}
  options[:with_evaluation_coeficient] = true
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold_evaluation_coeficient][t] = {}
    results[:token_treshold_evaluation_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_evaluation_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_evaluation_coeficient][t][:r_las]
    results[:token_treshold_evaluation_coeficient][t][:r_uas]
    results[:token_treshold_evaluation_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  s_short  = sentences.short 100
  s_medium = sentences.medium 100
  s_long   = sentences.long 100

  # short - token treshold change
  results[:token_treshold_s_short] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short][t] = {}
    results[:token_treshold_s_short][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short][t][:r_las]
    results[:token_treshold_s_short][t][:r_uas]
    results[:token_treshold_s_short][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium][t] = {}
    results[:token_treshold_s_medium][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium][t][:r_las]
    results[:token_treshold_s_medium][t][:r_uas]
    results[:token_treshold_s_medium][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long][t] = {}
    results[:token_treshold_s_long][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long][t][:r_las]
    results[:token_treshold_s_long][t][:r_uas]
    results[:token_treshold_s_long][t][:r_la]
  end


  # same with student coeficient
  options[:with_evaluation_coeficient] = true
  # short - token treshold change
  results[:token_treshold_s_short_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short_coeficient][t] = {}
    results[:token_treshold_s_short_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short_coeficient][t][:r_las]
    results[:token_treshold_s_short_coeficient][t][:r_uas]
    results[:token_treshold_s_short_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium_coeficient][t] = {}
    results[:token_treshold_s_medium_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium_coeficient][t][:r_las]
    results[:token_treshold_s_medium_coeficient][t][:r_uas]
    results[:token_treshold_s_medium_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long_coeficient][t] = {}
    results[:token_treshold_s_long_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long_coeficient][t][:r_las]
    results[:token_treshold_s_long_coeficient][t][:r_uas]
    results[:token_treshold_s_long_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  xml_file.write(results.to_xml)
  yaml_file.write(results.to_yaml)

  xml_file.flush
  yaml_file.flush
  xml_file.close
  yaml_file.close

  # --------------------------------------------------------------------------------------------------------------------
  # podmet
  results = {}
  yaml_file = File.open('results1.yaml', 'a')
  xml_file  = File.open('results1.xml', 'a')

  tresholds = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]

  options = {}
  options[:relation_treshold] = 0.2
  options[:drop_zero]         = true
  options[:tokens]            = [1]


  # sentences
  ids = [];Sentence.all.each { |s| ids << s.id if s.tasks.started.count > 10 && s.tasks.started.count < 100 }
  sentences = Sentence.where('id in (?)', ids)

  tasks = Task.started

  # altogether - token treshold change
  results[:token_treshold] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold][t] = {}
    results[:token_treshold][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold][t][:r_las]
    results[:token_treshold][t][:r_uas]
    results[:token_treshold][t][:r_la]
  end

  # altogether - token treshold change, with evaluation coeficient
  results[:token_treshold_evaluation_coeficient] = {}
  options[:with_evaluation_coeficient] = true
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold_evaluation_coeficient][t] = {}
    results[:token_treshold_evaluation_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_evaluation_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_evaluation_coeficient][t][:r_las]
    results[:token_treshold_evaluation_coeficient][t][:r_uas]
    results[:token_treshold_evaluation_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  s_short  = sentences.short 100
  s_medium = sentences.medium 100
  s_long   = sentences.long 100

  # short - token treshold change
  results[:token_treshold_s_short] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short][t] = {}
    results[:token_treshold_s_short][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short][t][:r_las]
    results[:token_treshold_s_short][t][:r_uas]
    results[:token_treshold_s_short][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium][t] = {}
    results[:token_treshold_s_medium][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium][t][:r_las]
    results[:token_treshold_s_medium][t][:r_uas]
    results[:token_treshold_s_medium][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long][t] = {}
    results[:token_treshold_s_long][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long][t][:r_las]
    results[:token_treshold_s_long][t][:r_uas]
    results[:token_treshold_s_long][t][:r_la]
  end


  # same with student coeficient
  options[:with_evaluation_coeficient] = true
  # short - token treshold change
  results[:token_treshold_s_short_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short_coeficient][t] = {}
    results[:token_treshold_s_short_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short_coeficient][t][:r_las]
    results[:token_treshold_s_short_coeficient][t][:r_uas]
    results[:token_treshold_s_short_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium_coeficient][t] = {}
    results[:token_treshold_s_medium_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium_coeficient][t][:r_las]
    results[:token_treshold_s_medium_coeficient][t][:r_uas]
    results[:token_treshold_s_medium_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long_coeficient][t] = {}
    results[:token_treshold_s_long_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long_coeficient][t][:r_las]
    results[:token_treshold_s_long_coeficient][t][:r_uas]
    results[:token_treshold_s_long_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  xml_file.write(results.to_xml)
  yaml_file.write(results.to_yaml)

  xml_file.flush
  yaml_file.flush
  xml_file.close
  yaml_file.close

  # --------------------------------------------------------------------------------------------------------------------
  # prisudok
  results = {}
  yaml_file = File.open('results2.yaml', 'a')
  xml_file  = File.open('results2.xml', 'a')

  tresholds = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]

  options = {}
  options[:relation_treshold] = 0.2
  options[:drop_zero]         = true
  options[:tokens]            = [2]


  # sentences
  ids = [];Sentence.all.each { |s| ids << s.id if s.tasks.started.count > 10 && s.tasks.started.count < 100 }
  sentences = Sentence.where('id in (?)', ids)

  tasks = Task.started

  # altogether - token treshold change
  results[:token_treshold] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold][t] = {}
    results[:token_treshold][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold][t][:r_las]
    results[:token_treshold][t][:r_uas]
    results[:token_treshold][t][:r_la]
  end

  # altogether - token treshold change, with evaluation coeficient
  results[:token_treshold_evaluation_coeficient] = {}
  options[:with_evaluation_coeficient] = true
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold_evaluation_coeficient][t] = {}
    results[:token_treshold_evaluation_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_evaluation_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_evaluation_coeficient][t][:r_las]
    results[:token_treshold_evaluation_coeficient][t][:r_uas]
    results[:token_treshold_evaluation_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  s_short  = sentences.short 100
  s_medium = sentences.medium 100
  s_long   = sentences.long 100

  # short - token treshold change
  results[:token_treshold_s_short] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short][t] = {}
    results[:token_treshold_s_short][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short][t][:r_las]
    results[:token_treshold_s_short][t][:r_uas]
    results[:token_treshold_s_short][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium][t] = {}
    results[:token_treshold_s_medium][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium][t][:r_las]
    results[:token_treshold_s_medium][t][:r_uas]
    results[:token_treshold_s_medium][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long][t] = {}
    results[:token_treshold_s_long][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long][t][:r_las]
    results[:token_treshold_s_long][t][:r_uas]
    results[:token_treshold_s_long][t][:r_la]
  end


  # same with student coeficient
  options[:with_evaluation_coeficient] = true
  # short - token treshold change
  results[:token_treshold_s_short_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short_coeficient][t] = {}
    results[:token_treshold_s_short_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short_coeficient][t][:r_las]
    results[:token_treshold_s_short_coeficient][t][:r_uas]
    results[:token_treshold_s_short_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium_coeficient][t] = {}
    results[:token_treshold_s_medium_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium_coeficient][t][:r_las]
    results[:token_treshold_s_medium_coeficient][t][:r_uas]
    results[:token_treshold_s_medium_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long_coeficient][t] = {}
    results[:token_treshold_s_long_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long_coeficient][t][:r_las]
    results[:token_treshold_s_long_coeficient][t][:r_uas]
    results[:token_treshold_s_long_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  xml_file.write(results.to_xml)
  yaml_file.write(results.to_yaml)

  xml_file.flush
  yaml_file.flush
  xml_file.close
  yaml_file.close

  # --------------------------------------------------------------------------------------------------------------------
  # predmet
  results = {}
  yaml_file = File.open('results3.yaml', 'a')
  xml_file  = File.open('results3.xml', 'a')

  tresholds = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]

  options = {}
  options[:relation_treshold] = 0.2
  options[:drop_zero]         = true
  options[:tokens]            = [3]


  # sentences
  ids = [];Sentence.all.each { |s| ids << s.id if s.tasks.started.count > 10 && s.tasks.started.count < 100 }
  sentences = Sentence.where('id in (?)', ids)

  tasks = Task.started

  # altogether - token treshold change
  results[:token_treshold] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold][t] = {}
    results[:token_treshold][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold][t][:r_las]
    results[:token_treshold][t][:r_uas]
    results[:token_treshold][t][:r_la]
  end

  # altogether - token treshold change, with evaluation coeficient
  results[:token_treshold_evaluation_coeficient] = {}
  options[:with_evaluation_coeficient] = true
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold_evaluation_coeficient][t] = {}
    results[:token_treshold_evaluation_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_evaluation_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_evaluation_coeficient][t][:r_las]
    results[:token_treshold_evaluation_coeficient][t][:r_uas]
    results[:token_treshold_evaluation_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  s_short  = sentences.short 100
  s_medium = sentences.medium 100
  s_long   = sentences.long 100

  # short - token treshold change
  results[:token_treshold_s_short] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short][t] = {}
    results[:token_treshold_s_short][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short][t][:r_las]
    results[:token_treshold_s_short][t][:r_uas]
    results[:token_treshold_s_short][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium][t] = {}
    results[:token_treshold_s_medium][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium][t][:r_las]
    results[:token_treshold_s_medium][t][:r_uas]
    results[:token_treshold_s_medium][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long][t] = {}
    results[:token_treshold_s_long][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long][t][:r_las]
    results[:token_treshold_s_long][t][:r_uas]
    results[:token_treshold_s_long][t][:r_la]
  end


  # same with student coeficient
  options[:with_evaluation_coeficient] = true
  # short - token treshold change
  results[:token_treshold_s_short_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short_coeficient][t] = {}
    results[:token_treshold_s_short_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short_coeficient][t][:r_las]
    results[:token_treshold_s_short_coeficient][t][:r_uas]
    results[:token_treshold_s_short_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium_coeficient][t] = {}
    results[:token_treshold_s_medium_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium_coeficient][t][:r_las]
    results[:token_treshold_s_medium_coeficient][t][:r_uas]
    results[:token_treshold_s_medium_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long_coeficient][t] = {}
    results[:token_treshold_s_long_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long_coeficient][t][:r_las]
    results[:token_treshold_s_long_coeficient][t][:r_uas]
    results[:token_treshold_s_long_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  xml_file.write(results.to_xml)
  yaml_file.write(results.to_yaml)

  xml_file.flush
  yaml_file.flush
  xml_file.close
  yaml_file.close

  # --------------------------------------------------------------------------------------------------------------------
  # privlastok
  results = {}
  yaml_file = File.open('results4.yaml', 'a')
  xml_file  = File.open('results4.xml', 'a')

  tresholds = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]

  options = {}
  options[:relation_treshold] = 0.2
  options[:drop_zero]         = true
  options[:tokens]            = [4]


  # sentences
  ids = [];Sentence.all.each { |s| ids << s.id if s.tasks.started.count > 10 && s.tasks.started.count < 100 }
  sentences = Sentence.where('id in (?)', ids)

  tasks = Task.started

  # altogether - token treshold change
  results[:token_treshold] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold][t] = {}
    results[:token_treshold][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold][t][:r_las]
    results[:token_treshold][t][:r_uas]
    results[:token_treshold][t][:r_la]
  end

  # altogether - token treshold change, with evaluation coeficient
  results[:token_treshold_evaluation_coeficient] = {}
  options[:with_evaluation_coeficient] = true
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold_evaluation_coeficient][t] = {}
    results[:token_treshold_evaluation_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_evaluation_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_evaluation_coeficient][t][:r_las]
    results[:token_treshold_evaluation_coeficient][t][:r_uas]
    results[:token_treshold_evaluation_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  s_short  = sentences.short 100
  s_medium = sentences.medium 100
  s_long   = sentences.long 100

  # short - token treshold change
  results[:token_treshold_s_short] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short][t] = {}
    results[:token_treshold_s_short][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short][t][:r_las]
    results[:token_treshold_s_short][t][:r_uas]
    results[:token_treshold_s_short][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium][t] = {}
    results[:token_treshold_s_medium][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium][t][:r_las]
    results[:token_treshold_s_medium][t][:r_uas]
    results[:token_treshold_s_medium][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long][t] = {}
    results[:token_treshold_s_long][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long][t][:r_las]
    results[:token_treshold_s_long][t][:r_uas]
    results[:token_treshold_s_long][t][:r_la]
  end


  # same with student coeficient
  options[:with_evaluation_coeficient] = true
  # short - token treshold change
  results[:token_treshold_s_short_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short_coeficient][t] = {}
    results[:token_treshold_s_short_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short_coeficient][t][:r_las]
    results[:token_treshold_s_short_coeficient][t][:r_uas]
    results[:token_treshold_s_short_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium_coeficient][t] = {}
    results[:token_treshold_s_medium_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium_coeficient][t][:r_las]
    results[:token_treshold_s_medium_coeficient][t][:r_uas]
    results[:token_treshold_s_medium_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long_coeficient][t] = {}
    results[:token_treshold_s_long_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long_coeficient][t][:r_las]
    results[:token_treshold_s_long_coeficient][t][:r_uas]
    results[:token_treshold_s_long_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  xml_file.write(results.to_xml)
  yaml_file.write(results.to_yaml)

  xml_file.flush
  yaml_file.flush
  xml_file.close
  yaml_file.close

  # --------------------------------------------------------------------------------------------------------------------
  # prislovkove urcenie
  results = {}
  yaml_file = File.open('results5.yaml', 'a')
  xml_file  = File.open('results5.xml', 'a')

  tresholds = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]

  options = {}
  options[:relation_treshold] = 0.2
  options[:drop_zero]         = true
  options[:tokens]            = [5]


  # sentences
  ids = [];Sentence.all.each { |s| ids << s.id if s.tasks.started.count > 10 && s.tasks.started.count < 100 }
  sentences = Sentence.where('id in (?)', ids)

  tasks = Task.started

  # altogether - token treshold change
  results[:token_treshold] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold][t] = {}
    results[:token_treshold][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold][t][:r_las]
    results[:token_treshold][t][:r_uas]
    results[:token_treshold][t][:r_la]
  end

  # altogether - token treshold change, with evaluation coeficient
  results[:token_treshold_evaluation_coeficient] = {}
  options[:with_evaluation_coeficient] = true
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, sentences, options)
    results[:token_treshold_evaluation_coeficient][t] = {}
    results[:token_treshold_evaluation_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_evaluation_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_evaluation_coeficient][t][:r_las]
    results[:token_treshold_evaluation_coeficient][t][:r_uas]
    results[:token_treshold_evaluation_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  s_short  = sentences.short 100
  s_medium = sentences.medium 100
  s_long   = sentences.long 100

  # short - token treshold change
  results[:token_treshold_s_short] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short][t] = {}
    results[:token_treshold_s_short][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short][t][:r_las]
    results[:token_treshold_s_short][t][:r_uas]
    results[:token_treshold_s_short][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium][t] = {}
    results[:token_treshold_s_medium][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium][t][:r_las]
    results[:token_treshold_s_medium][t][:r_uas]
    results[:token_treshold_s_medium][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long][t] = {}
    results[:token_treshold_s_long][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long][t][:r_las]
    results[:token_treshold_s_long][t][:r_uas]
    results[:token_treshold_s_long][t][:r_la]
  end


  # same with student coeficient
  options[:with_evaluation_coeficient] = true
  # short - token treshold change
  results[:token_treshold_s_short_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_short, options)
    results[:token_treshold_s_short_coeficient][t] = {}
    results[:token_treshold_s_short_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_short_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_short_coeficient][t][:r_las]
    results[:token_treshold_s_short_coeficient][t][:r_uas]
    results[:token_treshold_s_short_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_medium_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_medium, options)
    results[:token_treshold_s_medium_coeficient][t] = {}
    results[:token_treshold_s_medium_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_medium_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_medium_coeficient][t][:r_las]
    results[:token_treshold_s_medium_coeficient][t][:r_uas]
    results[:token_treshold_s_medium_coeficient][t][:r_la]
  end

  # medium - token treshold change
  results[:token_treshold_s_long_coeficient] = {}
  tresholds.each do |t|
    options[:token_treshold] = t

    data = process_batch(tasks, s_long, options)
    results[:token_treshold_s_long_coeficient][t] = {}
    results[:token_treshold_s_long_coeficient][t][:t_precision] = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positive] + data[:tokens][:tokens_negative])
    results[:token_treshold_s_long_coeficient][t][:t_recall]    = Float(data[:tokens][:tokens_positive])/Float(data[:tokens][:tokens_positives_overall])
    results[:token_treshold_s_long_coeficient][t][:r_las]
    results[:token_treshold_s_long_coeficient][t][:r_uas]
    results[:token_treshold_s_long_coeficient][t][:r_la]
  end

  options[:with_evaluation_coeficient] = false

  xml_file.write(results.to_xml)
  yaml_file.write(results.to_yaml)

  xml_file.flush
  yaml_file.flush
  xml_file.close
  yaml_file.close

  nil
end

