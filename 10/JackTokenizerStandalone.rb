require 'strscan'

class JackTokenizer
  KEYWORDS   = Regexp.union(%w(class constructor function method field static var int char boolean void true false null this let do if else while return))
  SYMBOLS    = Regexp.union("{}()[].,;+-*/&|<>=~".split(''))
  INT_CONST  = /\d+/
  STR_CONST  = /"(.*?)"/
  IDENTIFIER = /[a-zA-Z_]\w*/

  def initialize()
    if (ARGV.length == 1 && ARGV[0] =~ /.*\.jack$/)
      @source = ARGV[0]

      @scanner = StringScanner.new(IO.read(@source))

      File.open(generate_output_filename, "w") do |f|
        f.puts("<tokens>")
        until @scanner.eos?
          out = tokenize
          f.puts(out) if out
        end
        f.puts("</tokens>")
      end
    else
      puts "Usage: JackTokenizer.rb source"
      puts "source is a .jack file"
    end
  end

  def tokenize
    case
      when @scanner.scan(/\/\/.*$/)
      when @scanner.scan(/\/\*.*?\*\//m)
      when @scanner.scan(/\s/m)
      when @scanner.scan(KEYWORDS)
        "<keyword> #{@scanner.matched} </keyword>"
      when @scanner.scan(SYMBOLS)
        "<symbol> #{@scanner.matched.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')} </symbol>"
      when @scanner.scan(INT_CONST)
        "<integerConstant> #{@scanner.matched.to_i} </integerConstant>"
      when @scanner.scan(STR_CONST)
        "<stringConstant> #{@scanner.matched.gsub('"', '')} </stringConstant>"
      when @scanner.scan(IDENTIFIER)
        "<identifier> #{@scanner.matched} </identifier>"
    end
  end

  def generate_output_filename
    return @source.sub('.jack', 'T.xml')
  end
end

JackTokenizer.new
