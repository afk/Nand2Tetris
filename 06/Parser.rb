class Parser
  A_COMMAND = 1
  C_COMMAND = 2
  L_COMMAND = 3

  def initialize(filename)
    @lines = File.readlines(filename)
    @symbol_table = SymbolTable.new
    @output_lines = Array.new

    @lines.map! { |line|
      line.sub!(/\/\/.*$/, '')
      line.strip
    }
    @lines.delete_if { |line| line =~ /^\s*$/ }

    @current_address = 0
    @lines.each { |line| first_pass(line) }
    @current_address = 16
    @lines.each { |line| second_pass(line) }
  end

  def get_output
    @output_lines
  end

  def first_pass(line)
    @line = line

    if commandType == A_COMMAND || commandType == C_COMMAND
      @current_address += 1
    else
      @symbol_table.add_entry(symbol, @current_address)
    end
  end

  def second_pass(line)
    @line = line

    if commandType == A_COMMAND
      @output_lines.push(Code.a_instruction(get_address(symbol)))
    elsif commandType == C_COMMAND
      @output_lines.push(Code.c_instruction(comp(), dest(), jump()))
    else
      # nothing
    end
  end

  def commandType
    if @line =~ /^@.*/
      A_COMMAND
    elsif @line =~ /^\(.*/
      L_COMMAND
    else
      C_COMMAND
    end
  end

  def symbol
    /^[@\(](.*?)\)?$/.match(@line)[1]
  end

  def dest
    if /^(.*)=.*$/.match(@line)
      /^(.*)=.*$/.match(@line)[1]
    else
      ''
    end
  end

  def comp
    if /^.*=(.*)$/.match(@line)
      /^.*=(.*)$/.match(@line)[1]
    elsif /^(.*);.*$/.match(@line)
      /^(.*);.*$/.match(@line)[1]
    else
      ''
    end
  end

  def jump
    if /^.*;(.*)$/.match(@line)
      /^.*;(.*)$/.match(@line)[1]
    else
      ''
    end
  end

  def get_address(symbol)
    if symbol.numeric?
      symbol
    else
      if !@symbol_table.get_address(symbol)
        @symbol_table.add_entry(symbol, @current_address)
        @current_address += 1
      end
      @symbol_table.get_address(symbol)
    end
  end
end

class String
  def numeric?
    Float(self) != nil rescue false
  end
end
