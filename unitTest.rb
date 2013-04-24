############################################################################
#    Copyright (C) 2010 by Collins Williams                                #
#    cwilliam@leon                                                         #
#                                                                          #        
#                                                                          #
############################################################################
#WhiteSpaceToken = 0
#CommentToken = 1
#QuotedStringToken = 2
#WordToken = 3
require "lexer"
l = Lexer.new
l.addToken(nil, Regexp.new("\\s+", Regexp::MULTILINE))
l.addToken(nil, Regexp.new("#.*[\\n\\r]+"))
#l.addToken(nil, 4)
l.addToken(:quotedString,'["]((\\\")|[^\\\"])*"')
l.addToken(:Word,Regexp.new("\\w+"))
l.addToken(:LT,"<")
l.addToken(:doubleLT,"<<")
l.addToken(:GT,">")
#l.addToken(:errorTest,17)
foo = l.parseFile("testFile1") { |token, lexeme|
  puts "#{token}: #{lexeme}"
}
if foo
  puts "pass!"
else
  puts "fail: #{l.errString}"
end  