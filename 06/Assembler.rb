require './Parser'
require './Code'
require './SymbolTable'

class Assembler
  def initialize()
    if (ARGV.length == 1)
      @input_file = ARGV[0]
      assemble()
    else
      p "Usage: Assembler.rb file.asm"
    end
  end

  def assemble()
    parser = Parser.new(@input_file)
    File.open(Assembler.generate_output_filename(@input_file), "w+") do |f|
      f.puts(parser.get_output)
    end
  end

  def self.generate_output_filename(input_file)
    return input_file.sub('.asm', '.hack')
  end
end

Assembler.new
