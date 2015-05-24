class Code
  COMP_CODES = {
    '0' => '0101010', '1' => '0111111', '-1' => '0111010', 'D' => '0001100',
    'A' => '0110000', '!D' => '0001101', '!A' => '0110001', '-D' => '0001111',
    '-A' => '0110011', 'D+1' => '0011111', 'A+1' => '0110111', 'D-1' => '0001110',
    'A-1' => '0110010', 'D+A' => '0000010', 'D-A' => '0010011', 'A-D' => '0000111',
    'D&A' => '0000000', 'D|A' =>  '0010101',
    'M' => '1110000', '!M' => '1110001', '-M' => '1110011', 'M+1' => '1110111',
    'M-1' => '1110010', 'D+M' => '1000010', 'D-M' => '1010011', 'M-D' => '1000111',
    'D&M' => '1000000', 'D|M' => '1010101'
  }

  DEST_CODES = ['', 'M', 'D', 'MD', 'A', 'AM', 'AD', 'AMD']

  JUMP_CODES = ['', 'JGT', 'JEQ', 'JGE', 'JLT', 'JNE', 'JLE', 'JMP']

  def self.a_instruction(address)
    "0%015b" % address
  end

  def self.c_instruction(comp, dest, jump)
    "111#{Code.comp(comp)}#{Code.dest(dest)}#{Code.jump(jump)}"
  end

  def self.comp(comp)
    COMP_CODES[comp]
  end

  def self.dest(dest)
    "%03b" % DEST_CODES.index(dest)
  end

  def self.jump(jump)
    "%03b" % JUMP_CODES.index(jump)
  end
end
