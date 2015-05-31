require './Parser'
require './CodeWriter'

class VMTranslator
  def initialize()
    if (ARGV.length == 1)
      @source = ARGV[0]

      if @source =~ /.*\.vm$/
        translate(@source)
      else
        Dir.glob("#{@source}/*.vm") do |vm_file|
          translate(vm_file)
        end
      end

    else
      puts "Usage: VMTranslator.rb source"
      puts "source is a .vm file or a dir containing one or more .vm files"
    end
  end

  def translate(input_file)
    parser = Parser.new(input_file)
    File.open(VMTranslator.generate_output_filename(input_file), "w+") do |f|
      f.puts(parser.get_output)
    end
  end

  def self.generate_output_filename(input_file)
    if input_file =~ /.*\.vm$/
      return input_file.sub('.vm', '.asm')
    else
      return "#{input_file}.asm"
    end
  end
end

VMTranslator.new
