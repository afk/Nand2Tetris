class CodeWriter
  def initialize
    @output_lines = Array.new
    @lable_nr = 1
  end

  def get_output
    @output_lines
  end

  def push(segment, index)
    send "push_#{segment}", index
  end

  def push_constant(value)
    a_instruction(value)
    c_instruction('D', 'A')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def add
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'D+A')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def sub
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'A-D')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def neg
    dec_sp
    load_sp
    c_instruction('D', '-A')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def eq
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'A-D')
    lable_eq = "LABLE#{@lable_nr += 1}"
    a_instruction(lable_eq)
    c_instruction('', 'D', 'JEQ')
    load_sp
    c_instruction('M', '0')
    lable_ne = "LABLE#{@lable_nr += 1}"
    a_instruction(lable_ne)
    load_sp
    lable(lable_eq)
    c_instruction('M', '-1')
    lable(lable_ne)
    inc_sp
  end

  def gt
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'A-D')
    lable_eq = "LABLE#{@lable_nr += 1}"
    a_instruction(lable_eq)
    c_instruction('', 'D', 'JGT')
    load_sp
    c_instruction('M', '0')
    lable_ne = "LABLE#{@lable_nr += 1}"
    a_instruction(lable_ne)
    load_sp
    lable(lable_eq)
    c_instruction('M', '-1')
    lable(lable_ne)
    inc_sp
  end

  def lt
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'A-D')
    lable_eq = "LABLE#{@lable_nr += 1}"
    a_instruction(lable_eq)
    c_instruction('', 'D', 'JLT')
    load_sp
    c_instruction('M', '0')
    lable_ne = "LABLE#{@lable_nr += 1}"
    a_instruction(lable_ne)
    load_sp
    lable(lable_eq)
    c_instruction('M', '-1')
    lable(lable_ne)
    inc_sp
  end

  def and
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'D&A')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def or
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'D|A')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def not
    dec_sp
    load_sp
    c_instruction('D', '!A')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def inc_sp
    a_instruction('SP')
    c_instruction('M', 'M+1')
  end

  def dec_sp
    a_instruction('SP')
    c_instruction('M', 'M-1')
  end

  def load_sp
    a_instruction('SP')
    c_instruction('A', 'M')
  end

  def a_instruction(address)
    @output_lines.push "@#{address}"
  end

  def c_instruction(dest, comp, jump = '')
    unless dest.empty?
      line = "#{dest}=#{comp}"
    else
      line = "#{comp};#{jump}"
    end
    #line << ";#{jump}" unless jump.empty?
    @output_lines.push line
  end

  def lable(to_lable)
    @output_lines.push "(#{to_lable})"
  end
end
