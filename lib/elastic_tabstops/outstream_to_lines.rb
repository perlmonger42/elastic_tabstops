module ElasticTabstops
  require "stringio"

  class OutstreamToLines

    # INVARIANT: @text contains no newlines

    def initialize(liner)
      @text = ''
      @liner = liner
    end

    def puts(*args)
      sio = StringIO.new
      result = sio.puts(*args)
      add_text(sio.string)
      result
    end

    def print(*args)
      sio = StringIO.new
      result = sio.print(*args)
      add_text(sio.string)
      result
    end

    def write(*args)
      sio = StringIO.new
      result = sio.write(*args)
      add_text(sio.string)
      result
    end

    def flush
      @liner.line(@text) unless @text.empty?
      @liner.line('') # signals end-of-input to the @liner
    end

  private

    # Add text to @text.
    # Move completed lines (at the beginning of @text) to @liner.
    def add_text(text, flush: false)
      # ASSERTION: @text contains no newlines, due to class invariant
      @text += text

      # At this point, @text _may_ contain newlines, thus violating the class
      # invariant.  Move any full lines _out_ of @text and into @liner.
      pos = 0
      while (m = @text.match(/\G.*?\r?\n/, pos)) do
        @liner.line m[0]
        pos += m[0].size
      end
      @text = @text[pos..-1]

      # ASSERTION: @text contains no newlines; invariant has been restored
    end
  end
end
