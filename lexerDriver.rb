require "./lexer"
class LexerDriver
  # take a set of rules, a file, add the rules, parse the file
  def initialize
    @l = Lexer.new
  end
  
  #hand in an array of Rules
  def add_rules(rules)
    rules.each {|a_rule| @l.addToken(a_rule.tokID,a_rule.re)}
  end
  
  def add_rules_from_file(aFile)
    rule_file_lexer = Lexer.new()
    #parse a rule file with rules that look like this
    
    # # to end-of-line comments
    rule_file_lexer.addToken(nil, Regexp.new("#.*[\\n\\r]+"))
   
    # white space is not significant... nil tells lexer just to skip it
    rule_file_lexer.addToken(nil, Regexp.new("\\s+", Regexp::MULTILINE))
       
    # non comment lines with token_id and regular expressions separated by "==>"
    # the token_id should have the leading colon of a Ruby symbol
    # something like this
    # :token_id ==> "RegularExpressionForToken" # comment describing 
    # the regular expression can be singel or double quoted.  For my 
    # sanity whichevery delimiter is used may not appear in the reqular expression itself
    # so rules that include `'` may not include `"` 
    rule_file_lexer.addToken(:rule_token_name,Regexp.new(":\\w+"))
    rule_file_lexer.addToken(:rule_arrow,Regexp.new("==>"))
    rule_file_lexer.addToken(:rule_file_re,Regexp.new('"[^"]+"')) #any set of characters beginning and ending with `"`    
    rule_file_lexer.addToken(:rule_file_re,Regexp.new("'[^']+'")) #any set of characters beginning and ending with `'` 
    
    rule_number = 0
    state = 0
    result = rule_file_lexer.parseFile(aFile)   { |token, lexeme|
      # for now just see if we can parse the test rule file
      # puts "#{rule_number} #{token} #{lexeme}"
      case token
      when :rule_token_name   # waiting on a token
        if state == 0
          token_string = lexeme
          state = 1
        else
           raise "token name seen when state = #{state}"
        end
        
      when :rule_arrow
        if state == 1
          state = 2
        else
          raise "arrow seen when state = #{state}"
        end
        
      when :rule_file_re   
        if state == 2
          trimmed_re = lexeme[1..lexeme.length-2]
          puts "adding rule #{token_string} ==> #{trimmed_re}"
          @l.addToken(token_string,Regexp.new(trimmed_re))
          state = 0
          rule_number += 1
        else
          raise "#{aFile}: re seen when state = #{state}: #{lexeme}"
        end
      else
        raise "#{aFile}: unknown token #{token}"
      end
    }
    
    if result
      puts "rule file successfully parsed"
    else
      puts "fail: #{rule_number} : #{rule_file_lexer.errString}"
    end
  end
  
  def show_rules
    @l.show_rules
  end
  
  def file_set(aFile)
    @l.parseFile(aFile)
       
  end
  
  def errString
    @l.errString()
  end
  
  def parse_file
    l = Lexer.new
  end

end