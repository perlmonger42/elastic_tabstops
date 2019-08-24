#!/usr/bin/env ruby
require "ffaker"
require "bundler/setup"
require "elastic_tabstops"

def word
  FFaker::Lorem.word
end

def phrase(min_words=0, max_words=3)
  rand(min_words..max_words).times.map { word }.join(' ')
end

# Generate some sample data, in the form of hashes containing random text
keys = 5.times.map { phrase(1, 1) }
#=> ["iusto", "natus", "temporibus", "nobis", "sit"]

data = 10.times.map do
  values = keys.size.times.map { phrase(0,2) }
  Hash[keys.zip(values)]
end
#=> [{"iusto"=>"", "natus"=>"", "temporibus"=>"", "nobis"=>"sit", "sit"=>"explicabo blanditiis"},
#    {"iusto"=>"et", "natus"=>"nulla voluptas", "temporibus"=>"assumenda", "nobis"=>"omnis non", "sit"=>"autem"},
#    {"iusto"=>"repellendus distinctio", "natus"=>"consequuntur ipsum", "temporibus"=>"ut", "nobis"=>"", "sit"=>"sit"},
#    {"iusto"=>"cum", "natus"=>"", "temporibus"=>"", "nobis"=>"qui ipsa", "sit"=>"soluta ut"},
#    {"iusto"=>"", "natus"=>"nam ex", "temporibus"=>"delectus aut", "nobis"=>"", "sit"=>""},
#    {"iusto"=>"qui molestiae", "natus"=>"", "temporibus"=>"ut eos", "nobis"=>"qui vel", "sit"=>""},
#    {"iusto"=>"et nesciunt", "natus"=>"provident", "temporibus"=>"veniam autem", "nobis"=>"", "sit"=>""},
#    {"iusto"=>"", "natus"=>"", "temporibus"=>"sint accusamus", "nobis"=>"cumque voluptates", "sit"=>"voluptas"},
#    {"iusto"=>"est", "natus"=>"quidem", "temporibus"=>"rerum non", "nobis"=>"illo cupiditate", "sit"=>""},
#    {"iusto"=>"", "natus"=>"odio ratione", "temporibus"=>"porro", "nobis"=>"et numquam", "sit"=>""}]

# Write the array of hashes in colums.
# This method assumes that the first hash contains all the keys that matter.
def write_table(hashes)
  remember_original_stdout = $stdout
  $stdout = ElasticTabstops::make_stream($stdout);
  keys = hashes.first.keys
  puts keys.join("\t")
  puts keys.map { |k| '=' * k.size }.join("\t")
  hashes.each do |h|
    puts h.fetch_values(*keys).join("\t")
  end
  $stdout.flush
  $stdout = remember_original_stdout
end

write_table(data);
# iusto                  natus              temporibus     nobis             sit
# =====                  =====              ==========     =====             ===
#                                                          sit               explicabo blanditiis
# et                     nulla voluptas     assumenda      omnis non         autem
# repellendus distinctio consequuntur ipsum ut                               sit
# cum                                                      qui ipsa          soluta ut
#                        nam ex             delectus aut
# qui molestiae                             ut eos         qui vel
# et nesciunt            provident          veniam autem
#                                           sint accusamus cumque voluptates voluptas
# est                    quidem             rerum non      illo cupiditate
#                        odio ratione       porro          et numquam
