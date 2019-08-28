# ElasticTabstops
This is a Ruby implementation of
[elastic tabstops](http://nickgravgaard.com/elastic-tabstops/).

Aligning output columns can greatly improve the legibility of program output.
Unfortunately, that can be difficult to arrange.

Elastic tabstops are an elegant solution to that problem.  The idea is to
replace the classic "tabstops occur every 8 spaces" with the idea that
corresponding tabs on adjacent lines should define a column, and the tabstop
after that column's contents should be positioned to make that column just wide
enough for its data.

Tabs have always been elastic. This proposal makes the tab _stops_ elastic, as
well, by positioning them to fit the text.

As an example, this code writes several lines to an ElasticTabstops output
stream, where each line contains five tab-separated "words" of random length.
The elastic tabstops algorithm replaces tabs with spaces that neatly align the
columns.
```ruby
require "elastic_tabstops"

def word(letter); letter * rand(12) end;
def line(letters); letters.map { |letter| word(letter) }.join("\t") end;

et = ElasticTabstops::make_stream($stdout);
5.times do et.puts line(%w(a b c d e)) end; et.flush;
```
```text
aaaaaa     bbbbbbbbbbb c                eeeeeeeee
aaaaaaaaaa bbbbbbbbbb  cccc  ddddddddd  eeeeeeee
aaaaaaaa   bb          cc    ddddddd    eeeee
aaaaa      bbbbbb      ccccc dddddddddd ee
aaaa       bbb         ccccc ddddd      eeeeeeee
```

## Details

Data to be formatted as part of a column must be terminated with a tab character
(`"\t"`).  Any data that doesn't have a terminating tab (that is, from the last
tab to the end of the line) is not part of a column, and will be written
(without padding) following the last column.

A column is terminated by a line that doesn't contain that column. Having no
content in a column is okay, but if you want the column to continue
past that line, it must contain at least the tab terminator for that column.

This is easier to see with an example.
```
elastic_tabstops_stream = ElasticTabstops::make_stream($stdout);
[ "line 1: A|B|C",
  "line 2: a|b|c|",
  "line 3: aaa||cc|",
  "line 4: a|bbbbbbbb|c|",
  "line 5: A|",
  "line 6: A|X|Y|Z|",
  "line 7: a||yyyyyyyyyy|zzzz|",
  "line 8: a|x|yyy|z|",
  "line 9: aaaaaaaaaaaa|xx|yyyyy|z|",
].each { |s| elastic_tabstops_stream.puts s.gsub("|", "\t") }
elastic_tabstops_stream.flush # required (to process any buffered data)
```
(The `gsub` allows the example to use '|' as a visible stand-in for the required
tab characters.)

Here's the output:
```
line 1: A            B        C
line 2: a            b        c
line 3: aaa                   cc
line 4: a            bbbbbbbb c
line 5: A
line 6: A            X  Y          Z
line 7: a               yyyyyyyyyy zzzz
line 8: a            x  yyy        z
line 9: aaaaaaaaaaaa xx yyyyy      z
```

The first four lines have columns A, B, and C, but then line 5 has only
column A. That terminates columns B and C. Note that column B of line 3 is
empty, but column B continues to line 4 because the terminating tab was present.

Lines 6 through 9 have columns A, X, Y, and Z. Columns X and Y are unconnected
to columns B and C, because B and C were terminated at line 5.

Column A is never broken, so it spans the entire output.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'elastic_tabstops'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elastic_tabstops

## Usage

First, you create an ElasticTabstop output stream. The `make_stream` takes a
single argument, which is the output stream you want to receive the formatted
results.
```ruby
  stream = ElasticTabstops::make_stream($stdout);
```

Then, write your data to the stream, terminating each column's data
with a tab. Any data (at the end of line) that doesn't end in a tab is not
part of a column, and will be written following the last column.

ElasticTabstops streams provide `puts`, `print`, and `write` methods.

When you're done writing to the stream, you need to call its `flush` method.
The algorithm has to buffer the output data, because it can't generate
output until it knows how wide the columns are, and it can't know for sure how
wide the columns are until all the column data has been seen.
The `flush` tells the stream to close off all open columns and emit the output.

Generating an output line with no tab characters will also flush the buffer,
because it terminates all open columns.

Here's a more extensive demo. It prints an array of hashes as a table.
```ruby
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

# Write the array of hashes in columns.
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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at `https://github.com/perlmonger42/elastic-tabstops`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
