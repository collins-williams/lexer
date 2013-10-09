#!/usr/bin/ruby -w
# this is a test that overlapping rules can be resolved by priorities
# 
require "./lexerDriver.rb"
ld = LexerDriver.new()
result = ld.add_rules_from_file("./test7_rule_file")
#this is a test of having rules that contain character classes and escaped chars
parse = true
state = 0
err_string = "success"
result = ld.file_set("./test7_text_file") { |token, lexeme|
  if lexeme === "for"
    if token != :for_token.inspect
      puts "ut7 fail :for_token not found #{token} #{lexeme}"
      return
    end
  end
  puts "ut7: #{token.class.name} #{token} #{lexeme} #{state}"  
}
if result
  puts "pass!"
else
  puts "fail!"
end