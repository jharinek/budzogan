require 'json'
require 'pry'
require_relative './processed_task.rb'
require_relative './token.rb'

def process_task(task)
  solution = JSON.parse task.student_solution.to_json
  links    = []
  nodes    = []

  processed_task = ProcessedTask.new(task.sentence, task)

  solution["cells"].each do |cell|
    cell["type"] == "link" ? links << cell : nodes << cell
  end

# now process the nodes to desired format
  processed_nodes = []
  processed_links = []
  ids_hash        = {}

  sentence = task.sentence
  words    = sentence.content.split ' '

  words.each { |w| processed_task.tokens << Token.new(w) }

# process nodes
  nodes.each_with_index do |node, i|
    processed_node = {}
    properties     = node["attrs"]["rect"]["class"].split
    properties.delete 'properties'

    processed_node[:id]          = i
    processed_node[:task_id]     = task.id
    processed_node[:sentence_id] = sentence.id
    processed_node[:text]        = node["attrs"]["text"]["text"].strip.gsub(/\b[a-zA-Z][a-zA-Z]\b | \b[a-zA-Z][a-zA-Z]\b| \b[a-zA-z]\b|\b[a-zA-z]\b /, '')
    processed_node[:word_id]     = resolve_word_index words, processed_node[:text]
    processed_node[:l1_property] = properties[0]
    processed_node[:l2_property] = properties[1]
    processed_node[:l3_property] = properties[2]
    processed_node[:children]    = []

    ids_hash[node["id"].to_sym] = processed_node[:word_id]

    processed_nodes << processed_node

    processed_node[:text].split(' ').each do |part|
      part.gsub!('.', '')
      part.gsub!('!', '')
      part.gsub!('?', '')
      part.gsub!(',', '')
      part.gsub!(';', '')

      i = processed_task.tokens.index { |t| t.text == part }

      processed_task.tokens[i].properties[0] = properties[0]
      processed_task.tokens[i].properties[1] = properties[1]
      processed_task.tokens[i].properties[2] = properties[2]

    end
  end

# process links
  links.each do |link|
    processed_link = {}

    source = link["source"]["id"]
    target = link["target"]["id"]

    processed_link[:type]      = link["labels"][0]["attrs"]["text"]["text"].strip
    processed_link[:node_1_id] = source ? ids_hash[link["source"]["id"].to_sym] : ''
    processed_link[:node_2_id] = target ? ids_hash[link["target"]["id"].to_sym] : ''

    id_1 = processed_nodes.index { |x| x[:word_id] == processed_link[:node_1_id] } if source
    id_2 = processed_nodes.index { |x| x[:word_id] == processed_link[:node_2_id] } if target

    processed_nodes[id_1][:children] << [ processed_link[:node_2_id], processed_link[:type] ] if source
    processed_nodes[id_2][:children] << [ processed_link[:node_1_id], processed_link[:type] ] if target

    processed_links << processed_link
  end


  solution         = {}
  solution[:nodes] = processed_nodes
  solution[:links] = processed_links
  solution
end

def initialize_data_array
  data_array = Hash.new
  Sentence.all.each do |s|
    data_array[s.id] = Hash.new
    data_array[s.id][:student_solutions]  = []
    data_array[s.id][:extracted_solution] = nil
    data_array[s.id][:correct_solution]   = nil
    data_array[s.id][:statistics]         = nil
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

def summarize_data
  raw_data       = process_all_tasks
  processed_data = initialize_data_array

  raw_data.each_with_index do |sentence_data, index|
    processed_data[index]            = {}

    if sentence_data
      processed_data[index][:elements] = []
      processed_data[index][:samples_count] = 0
      processed_data[index][:sentence] = Sentence.find(index).content

      sentence_data.each do |sample|
        processed_data[index][:samples_count] += 1
        sample[:nodes].each do |node|
          id = node[:word_id]
          processed_data[index][:elements][id] ||= {}
          processed_data[index][:elements][id][:word] = node[:text]
          processed_data[index][:elements][id][:l1_property] ||= Array.new(6, 0)
          processed_data[index][:elements][id][:l2_property] ||= Array.new(7, 0)
          processed_data[index][:elements][id][:l3_property] ||= Array.new(6, 0)
          processed_data[index][:elements][id][:children] ||= Hash.new(0)
          processed_data[index][:elements][id][:samples_count] ||= 0

          processed_data[index][:elements][id][:l1_property][node[:l1_property].to_i] += 1
          processed_data[index][:elements][id][:l2_property][node[:l2_property].to_i] += 1
          processed_data[index][:elements][id][:l3_property][node[:l3_property].to_i] += 1

          node[:children].each do |child|
            word = (sample[:nodes].find { |n| n[:word_id] == child[0].to_i})
            word = word[:text] if word
            processed_data[index][:elements][id][:children]["#{child[1]}_#{child[0]}_#{word}".to_sym] += 1
          end

          processed_data[index][:elements][id][:samples_count] += 1
        end
      end
    end
  end

  processed_data
end

def pretty_print_data
  data = summarize_data
  i = 1
  File.open('./output.txt','w') do |f|
    data.each do |sentence|
      next if sentence.empty?
      f.puts i
      f.puts "#{sentence[:sentence]}(#{sentence[:samples_count]})"

      sentence[:elements].each do |word|
        next unless word
        f.puts "#{word[:word]}(#{word[:samples_count]}): l1:#{evaluate_property(word[:l1_property], word[:samples_count])}, l2:#{evaluate_property(word[:l2_property], word[:samples_count])},l3:#{evaluate_property(word[:l3_property], word[:samples_count])}, sklady:#{evaluate_connections(word[:children], word[:samples_count])}"
      end

      f.puts "\n"
      f.puts '---------------------------------------------------'
      i += 1
    end
  end
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
