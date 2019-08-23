module ElasticTabstops
  class Formatter

    def initialize(output_stream, tabchar: "\t", padchar: ' ')
      @outstream = output_stream
      @lines = []
      @ctrls = []
      @tabchar = tabchar
      @padchar = padchar
      @split_re = /(?<=#{Regexp.escape(tabchar)})/
    end

    # PRECONDITION: text == '' || /\A.*\r?\n\z/ === text
    # In the regex above, `\A` matches beginning-of-string, and `\z` matches
    # end-of-string. The absence of a multiline modifier (as in /abc/m) means
    # `.` does NOT match newline.
    #
    # So, in English: `text` is a string, and it is either the empty string, or
    # it is a sequence of non-newline characters terminated by a newline.
    def line(text)
      texts = text.split(@split_re)

      # Ensure that a non-tab-terminated text exists at the end of texts
      texts << '' if texts.empty? || texts[-1][-1] == @tabchar

      emit_line_of_cells(texts)
    end

  private

    # PRECONDITION: texts === Array && texts.size > 0 && texts[-1][-1] != @tabchar
    def emit_line_of_cells(texts)
      # Remove the non-tab-terminated cell from the end.
      last = texts.pop

      # Make sure `@ctrls` covers all columns in this input line.
      @ctrls.push({ width: 0 }) while @ctrls.size < texts.size

      # Convert the array of strings into an array of cell hashes
      cells = texts.map.with_index do |text, i|
        text = text[0..-2] # remove trailing tab
        ctrl = @ctrls[i]
        ctrl[:width] = text.size if text.size > ctrl[:width]
        { text: text, ctrl: ctrl }
      end

      # Remove ctrl cells for columns that don't appear in this line.
      # Such columns had data in the previous output line, but not this one.
      @ctrls.pop while @ctrls.size > cells.size

      # Restore the special `last` cell, and store the cells in @lines.
      cells << { text: last } # NOTE: no :ctrl field
      @lines.push(cells)

      # If cells.size == 1, it's only the special `last` cell; there are no
      # formattable columns in this line. That means all the pending output
      # columns have terminated, and we finally know the :width's are final.
      write_formatted_text_to_output if cells.size == 1
    end

    def write_formatted_text_to_output
      @lines.each do |line|
        line.each do |cell|
          s = cell[:text]
          @outstream.write(s)
          if cell.key?(:ctrl)
            @outstream.write(@padchar * (cell[:ctrl][:width] + 1 - s.size))
          end
        end
      end
      @lines = []
    end
  end
end
