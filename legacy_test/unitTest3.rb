#!/usr/bin/ruby -w
require "./lexerDriver.rb"
ld = LexerDriver.new()
ld.add_rules_from_file("./test3_rule_file")
ld.show_rules()
result = ld.file_set("./test3_text_file") { |token, lexeme|
  
}
if result
  puts "pass!"
else
  puts "fail: #{ld.errString}"
end