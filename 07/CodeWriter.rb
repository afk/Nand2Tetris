class CodeWriter
  def initialize
    @output_lines = Array.new
    @lable_nr = 1
  end

  def get_output
    @output_lines
  end

  def filename=(filename)
    @filename = filename
  end

  def add
    comp_two_values_from_sp('D+M')
  end

  def sub
    comp_two_values_from_sp('M-D')
  end

  def neg
    comp_one_value_from_sp('-D')
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
    comp_two_values_from_sp('D&M')
  end

  def or
    comp_two_values_from_sp('D|M')
  end

  def not
    comp_one_value_from_sp('!D')
  end

  def push(segment, index)
    send "push_#{segment}", index
  end

  def push_argument(index)
    push_mem_to_stack('ARG', index)
  end

  def push_local(index)
    push_mem_to_stack('LCL', index)
  end

  def push_static(value)
    a_instruction(static_symbol(value))
    push_reg_to_stack('M')
  end

  def push_constant(value)
    push_val_to_stack(value)
  end

  def push_this(index)
    push_mem_to_stack('THIS', index)
  end

  def push_that(index)
    push_mem_to_stack('THAT', index)
  end

  def push_pointer(index)
    reg_index_offset('3', index)
    push_reg_to_stack('M')
  end

  def push_temp(index)
    a_reg_index_offset('5', index)
    push_reg_to_stack('M')
  end

  def pop(segment, index)
    send "pop_#{segment}", index
  end

  def pop_argument(index)
    pop_sp_to_mem('ARG', index)
  end

  def pop_local(index)
    pop_sp_to_mem('LCL', index)
  end

  def pop_static(value)
    a_instruction(static_symbol(value))
    c_instruction('D', 'A')
    a_instruction('R13')
    c_instruction('M', 'D')
    load_sp
    c_instruction('D', 'M')
    a_instruction('R13')
    c_instruction('A', 'M')
    c_instruction('M', 'D')
  end

  def pop_this(index)
    pop_sp_to_mem('THIS', index)
  end

  def pop_that(index)
    pop_sp_to_mem('THAT', index)
  end

  def pop_pointer(index)
    pop_sp_to_reg('3', index)
  end

  def pop_temp(index)
    pop_sp_to_reg('5', index)
  end

  ### Internal ###

  def comp_one_value_from_sp(comp)
    dec_sp
    load_sp
    c_instruction('D', 'M')
    c_instruction('M', comp)
    inc_sp
  end

  def comp_two_values_from_sp(comp)
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('M', comp)
    inc_sp
  end

  def a_reg_index_offset(reg, index)
    a_instruction(index)
    c_instruction('D', 'A')
    a_instruction(reg)
    c_instruction('A', 'D+A')
  end

  def push_val_to_stack(val)
    a_instruction(val)
    c_instruction('D', 'A')
    load_sp
    c_instruction('M', 'D')
    inc_sp
  end

  def push_reg_to_stack(reg = 'D')
    c_instruction('D', reg) unless reg == 'D'
    load_sp
    c_instruction('M', reg)
    inc_sp
  end

  def push_mem_to_stack(seg, index)
    a_instruction(index)
      c_instruction('D', 'A')
    a_instruction(seg)
    c_instruction('A', 'D+M')
      c_instruction('D', 'M')
    push_reg_to_stack
  end

  def pop_sp_to_mem(seg, index = 0)
    if index
      a_instruction(index)
        c_instruction('D', 'A')
      a_instruction(seg)
        c_instruction('D', 'D+M')
      a_instruction('R13')
        c_instruction('M', 'D')
      load_sp
        c_instruction('D', 'M')
      a_instruction('R13')
      c_instruction('A', 'M')
        c_instruction('M', 'D')
    else
      load_sp
        c_instruction('D', 'M')
      a_instruction(seg)
        c_instruction('M', 'D')
    end
  end

  def pop_sp_to_reg(reg, index)
    if index
      a_instruction(index)
        c_instruction('D', 'A')
      a_instruction(reg)
        c_instruction('D', 'D+A')
      a_instruction('R13')
        c_instruction('M', 'D')
      load_sp
        c_instruction('D', 'M')
      a_instruction('R13')
      c_instruction('A', 'M')
        c_instruction('M', 'D')
    else
      load_sp
        c_instruction('D', 'M')
      a_instruction(reg)
        c_instruction('M', 'D')
    end
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

  def static_symbol(var)
    "#{@filename.sub('.vm', '')}.#{var}"
  end
end
