#!/usr/bin/ruby -w
require "./lexerDriver.rb"
ld = LexerDriver.new()
result = ld.add_rules_from_file("./test6_rule_file")
#this is a test of having rules that contain character classes and escaped chars
parse = true
state = 0
err_string = "success"
result = ld.file_set("./test6_text_file") { |token, lexeme|
  puts "ut6: #{token.class.name} #{token} #{lexeme} #{state}"  
}
if result
  puts "pass!"
else
  puts "fail!"
end