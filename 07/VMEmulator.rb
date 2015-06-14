require './Parser'
require './CodeWriter'

class VMEmulator
  def initialize()
    if (ARGV.length == 1)
      @source = ARGV[0]

      if @source =~ /.*\.vm$/
        emulate(@source)
      else
        Dir.glob("#{@source}/*.vm") do |vm_file|
          emulate(vm_file)
        end
      end

    else
      puts "Usage: VMTranslator.rb source"
      puts "source is a .vm file or a dir containing one or more .vm files"
    end
  end

  def emulate(input_file)
    parser = Parser.new(input_file)
    parser.get_output
  end
end

VMEmulator.new
