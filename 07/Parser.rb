class Parser
  ZERO_ARG = 0
  ONE_ARG = 1
  TWO_ARG = 2

  def initialize(filename, code_handler)
    @lines = File.readlines(filename)
    @code_handler = code_handler

    @lines.map! { |line|
      line.sub!(/\/\/.*$/, '')
      line.strip
    }
    @lines.delete_if { |line| line =~ /^\s*$/ }

    @lines.each { |line|
      @line = line

      if commandType == ZERO_ARG
        @code_handler.send line
      elsif commandType == ONE_ARG
        @code_handler.send cmd, arg1
      elsif commandType == TWO_ARG
        @code_handler.send cmd, arg1, arg2
      end
    }
  end

  def get_output
    @code_handler.get_output
  end

  def commandType
    with_one_arg = /^(.*) .*$/.match(@line)[1] if /^(.*) .*$/.match(@line)
    with_two_arg = /^(.*) .* .*$/.match(@line)[1] if /^(.*) .* .*$/.match(@line)

    if ['add', 'sub', 'neg', 'eq', 'gt', 'lt', 'and', 'or', 'not', 'return'].include? @line
      ZERO_ARG
    elsif ['label', 'goto', 'if-goto'].include? with_one_arg
      ONE_ARG
    elsif ['push', 'pop', 'function', 'call'].include? with_two_arg
      TWO_ARG
    end
  end

  def cmd
    if commandType == ZERO_ARG
      @line
    elsif commandType == ONE_ARG
      /^(.*) .*$/.match(@line)[1]
    elsif commandType == TWO_ARG
      /^(.*) .* .*$/.match(@line)[1]
    end
  end

  def arg1
    if commandType == ZERO_ARG && @line != 'return'
      @line
    elsif commandType == ONE_ARG
      /^.* (.*)$/.match(@line)[1]
    elsif commandType == TWO_ARG
      /^.* (.*) .*$/.match(@line)[1]
    end
  end

  def arg2
    if commandType == TWO_ARG
      /^.* .* (.*)$/.match(@line)[1]
    end
  end
end
