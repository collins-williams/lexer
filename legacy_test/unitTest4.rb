#!/usr/bin/ruby -w
require "./lexerDriver.rb"
ld = LexerDriver.new()
result = ld.add_rules_from_file("./test4_rule_file")
# this test expects to fail the rule adding
if result
  puts "fail!  should ahave detected an incomplete rule"
else
  puts "pass!"
end
