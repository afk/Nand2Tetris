require './Parser'
require './CodeWriter'

class VMTranslator
  def initialize()
    if (ARGV.length == 1)
      @source = ARGV[0]
      @code_writer = CodeWriter.new

      if File.file? generate_output_filename
        File.delete generate_output_filename
      end

      if @source =~ /.*\.vm$/
        translate(@source)
      else
        Dir.glob("#{@source}/*.vm") do |vm_file|
          translate(vm_file, generate_output_filename)
        end
      end

    else
      puts "Usage: VMTranslator.rb source"
      puts "source is a .vm file or a dir containing one or more .vm files"
    end
  end

  def translate(input_file, output_file = false)
    output_file = generate_output_filename unless output_file

    parser = Parser.new(input_file, @code_writer)

    File.open(output_file, "a") do |f|
      f.puts(parser.get_output)
    end
  end

  def generate_output_filename
    if @source =~ /.*\.vm$/
      return @source.sub('.vm', '.asm')
    else
      name = /\/([^\/]*)\/$/.match(@source)[1]
      return "#{@source}#{name}.asm"
    end
  end
end

VMTranslator.new
