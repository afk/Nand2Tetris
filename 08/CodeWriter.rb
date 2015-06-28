class CodeWriter
  def initialize
    @output_lines = Array.new
    @label_nr = 0

    init
  end

  def get_output
    old = @output_lines
    @output_lines = Array.new
    old
  end

  def filename=(filename)
    @filename = filename
  end

  def init
    a_instruction('256')
    c_instruction('D', 'A')
    a_instruction('SP')
    c_instruction('M', 'D')
    call('Sys.init', 0)
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

  def compare(comp)
    dec_sp
    load_sp
    c_instruction('D', 'M')
    dec_sp
    load_sp
    c_instruction('D', 'M-D')
    label_eq = "LABEL#{@label_nr += 1}"
    a_instruction(label_eq)
    c_instruction('', 'D', comp)
    load_sp
    c_instruction('M', '0')
    label_ne = "LABEL#{@label_nr += 1}"
    a_instruction(label_ne)
    c_instruction('', '0', 'JMP')
    label(label_eq)
    load_sp
    c_instruction('M', '-1')
    label(label_ne)
    inc_sp
  end

  def eq
    compare('JEQ')
  end

  def gt
    compare('JGT')
  end

  def lt
    compare('JLT')
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
    a_reg_index_offset('3', index)
    push_reg_to_stack('M')
  end

  def push_temp(index)
    a_reg_index_offset('5', index)
    push_reg_to_stack('M')
  end

  def pop(segment, index)
    dec_sp
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

  def label(label)
    @output_lines.push "(#{label})"
  end

  def goto(label)
    a_instruction(label)
    c_instruction('', '0', 'JMP')
  end

  def if_goto(label)
    dec_sp
    load_sp
    c_instruction('D', 'M')
    a_instruction(label)
    c_instruction('', 'D', 'JNE')
  end

  def call(f, n)
    ret = "LABEL#{@label_nr += 1}"
    push('constant', ret)

    a_instruction('LCL')
    push_reg_to_stack('M')

    a_instruction('ARG')
    push_reg_to_stack('M')

    a_instruction('THIS')
    push_reg_to_stack('M')

    a_instruction('THAT')
    push_reg_to_stack('M')

    a_reg_index_offset('SP', -n.to_i-5)
    c_instruction('D', 'A')
    a_instruction('ARG')
    c_instruction('M', 'D')

    a_instruction('SP')
    c_instruction('D', 'M')
    a_instruction('LCL')
    c_instruction('M', 'D')

    goto(f)

    label ret
  end

  def function(f, k)
    label f
    (0..k.to_i).each do
      push('constant', 0)
    end
  end

  def return
    a_instruction('LCL')
    c_instruction('D', 'M')
    a_instruction('R14')
    c_instruction('M', 'D')

    a_instruction('5')
    c_instruction('A', 'D-A')
    c_instruction('D', 'M')
    a_instruction('R15')
    c_instruction('M', 'D')

    pop('argument', 0)

    a_instruction('ARG')
    c_instruction('D', 'M')
    a_instruction('SP')
    c_instruction('M', 'D+1')

    a_instruction('R14')
    c_instruction('AM', 'M-1')
    c_instruction('D', 'M')
    a_instruction('THAT')
    c_instruction('M', 'D')

    a_instruction('R14')
    c_instruction('AM', 'M-1')
    c_instruction('D', 'M')
    a_instruction('THIS')
    c_instruction('M', 'D')

    a_instruction('R14')
    c_instruction('AM', 'M-1')
    c_instruction('D', 'M')
    a_instruction('ARG')
    c_instruction('M', 'D')

    a_instruction('R14')
    c_instruction('AM', 'M-1')
    c_instruction('D', 'M')
    a_instruction('LCL')
    c_instruction('M', 'D')

    a_instruction('R15')
    c_instruction('A', 'M')
    c_instruction('', '0', 'JMP')
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

  def a_reg_index_offset(reg, index = 0)
    if index < 0
      index = -index
      comp = 'M-D'
    else
      comp = 'D+A'
    end
    a_instruction(index)
    c_instruction('D', 'A')
    a_instruction(reg)
    c_instruction('A', comp)
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
    c_instruction('M', 'D')
    inc_sp
  end

  def push_mem_to_stack(seg, index)
    a_instruction(index)
      c_instruction('D', 'A')
    a_instruction(seg)
    c_instruction('A', 'D+M')
    push_reg_to_stack('M')
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

  def pop_sp_to_reg(reg, index = 0)
    if index != 0
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

  def static_symbol(var)
    "#{@filename.sub('.vm', '')}.#{var}"
  end
end
