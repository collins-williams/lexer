#!/usr/bin/ruby -w
require "./lexerDriver.rb"
ld = LexerDriver.new()
ld.add_rules_from_file("./test_rule_file")