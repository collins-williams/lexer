#!/usr/bin/ruby -w
require "./lexerDriver.rb"
ld = LexerDriver.new()
result = ld.add_rules_from_file("./test5_rule_file")
#this is a test of having rules that contain re meaningful characters such as `{`
parse = true
state = 0
err_string = "success"
result = ld.file_set("./test5_text_file") { |token, lexeme|
  puts "ut5: #{token.class.name} #{token} #{lexeme} #{state}"
  case state
  when 0
    if token === :for_token.inspect
      state = 1
    else
      parse = false
      raise "wrong token in state #{state}: #{token} #{lexeme}"

    end
  when 1
    if token === :brace_token.inspect
      state = 2
    else
      parse = false
      err_string = "wrong token in state #{state}: #{token} #{lexeme}"
    end
  when 2
    if token === :double_quote_token.inspect
      state = 3
    else
      parse = false
      err_string = "wrong token in state #{state}: #{token} #{lexeme}"
    end
  else
    parse = false
    err_string = "wrong token in state #{state}: #{token} #{lexeme}"
  end
}
if result && parse && state == 3
  puts "pass!"
else
  puts "fail: #{ld.errString}  #{err_string} #{state}"
end
