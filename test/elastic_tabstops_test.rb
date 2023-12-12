require "stringio"
require "test_helper"
require "minitest/rg"

class ElasticTabstopsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ElasticTabstops::VERSION
  end

  def test_noop
    string_io = StringIO.new
    stream = ElasticTabstops::make_stream(string_io)
    stream.write "Hello, world!\nHasta la vista, mundo!\n"
    stream.flush
    assert_equal "Hello, world!\nHasta la vista, mundo!\n", string_io.string
  end

  def test_single_line
    string_io = StringIO.new
    stream = ElasticTabstops::make_stream(string_io)
    stream.puts "a\tb\tc\td"
    stream.flush
    assert_equal "a b c d\n", string_io.string
  end

  def test_no_newline
    string_io = StringIO.new
    stream = ElasticTabstops::make_stream(string_io)
    stream.write "w\tx\ty\tz"
    stream.flush
    assert_equal "w x y z", string_io.string
  end

  def test_two_columns
    string_io = StringIO.new
    stream = ElasticTabstops::make_stream(string_io, padchar: '·', tabchar: '|')
    stream.puts "a|bbbbb|pqr\n"
    stream.puts "aaa|b|s\n"
    stream.puts "aaa|b|\n"
    stream.puts "aa|bb|tuvwxyz\n"
    stream.puts "a|b|\n"
    stream.flush
    assert_equal <<EOS.inspect, string_io.string.inspect
a···bbbbb·pqr
aaa·b·····s
aaa·b·····
aa··bb····tuvwxyz
a···b·····
EOS
  end

  def t(input, expected_output, padchar: ' ')
    string_io = StringIO.new
    stream = ElasticTabstops::make_stream(string_io, padchar: padchar)
    stream.write input
    stream.flush
    assert_equal expected_output, string_io.string
  end

  def test_empty; t('', ''); end
  def test_word; t('foo', 'foo') end
  def test_word_tab_word; t "foo\tbar", "foo bar" end
  def test_x0_0x; t "foo\t\n\tbar", "foo \n    bar" end
  def test_x0_0xn; t "foo\t\n\tbar\n", "foo \n    bar\n" end

  def test_000_xyz_xyz
    t "\t\t\t\nx\tyyy\tzz\t\nxxx\ty\tzz\t\n",
      "···········\n" +
      "x···yyy·zz·\n" +
      "xxx·y···zz·\n",
      padchar: '·'
  end

  def test_ending_columns
    t "xxxxx\tyyyy\tzzz\t.\n" +
      "xxxxx\tyyyy\tzzzzzz\t.\n" +
      "xxxx\ty\t.\n" +
      "xxxx\tyyy\t.\n" +
      "xxx\tyy\t.\n" +
      "x\t.\n" +
      "xx\t.\n" +
      "xxxxxxxxx\tyyyyyyyyy\t.\n" +
      "x\ty\t.\n" +
      "x\ty\tzz\t.\n" +
      "x\ty\tzz\t.\n",

      "xxxxx·····yyyy·zzz····.\n" +
      "xxxxx·····yyyy·zzzzzz·.\n" +
      "xxxx······y····.\n" +
      "xxxx······yyy··.\n" +
      "xxx·······yy···.\n" +
      "x·········.\n" +
      "xx········.\n" +
      "xxxxxxxxx·yyyyyyyyy·.\n" +
      "x·········y·········.\n" +
      "x·········y·········zz·.\n" +
      "x·········y·········zz·.\n",

      padchar: '·'
  end
end
