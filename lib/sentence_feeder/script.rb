require 'nokogiri'
require './extractor.rb'

puts "Preparing for extraction from #{ARGV[0]}"

directory = ARGV[0] + '/*'
files     = Dir[directory]

e = Extractor.new('./sentences.txt')

files.each do |filename|
  puts "Processing #{filename}..."
  doc = Nokogiri::XML(File.open(filename))

  e.extract_sentences(doc, filename)
end

puts 'Done!'
