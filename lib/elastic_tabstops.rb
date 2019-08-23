require "elastic_tabstops/version"
require "elastic_tabstops/formatter"
require "elastic_tabstops/outstream_to_lines"
require 'English'

module ElasticTabstops
  class Error < StandardError; end

  def self.make_stream(output_stream, tabchar: "\t", padchar: ' ')
    formatter = ElasticTabstops::Formatter.new(
      output_stream,
      tabchar: tabchar,
      padchar: padchar
    )
    ElasticTabstops::OutstreamToLines.new(formatter)
  end
end
