#!/usr/bin/env ruby -w

Rule = Struct.new :tokID, :re

Match = Struct.new :rule, :lexeme

class Lexer
  attr_reader :errString
  # keep a collection of regular expressions and values to return as token 
  # types
  # then match text to the longest substring yet seen
  def initialize
    @rules = []
    @buff = ""
  end
  
  def addToken (tokID, re)
    # prepend all regexp with \\A so that they only match at tbe beginning of a 
    # line
    @rules << Rule.new(tokID,
      case re
        when String
          Regexp.new("\\A" + re)
        when Regexp
          Regexp.new("\\A" + re.source)
        else
          raise ArgumentError, "#{re.class.name} passed to addToken"
      end
    )
  end
  
  def show_rules
    @rules.each { |aRule|
      puts "#{aRule.tokID} #{aRule.re.source}"
    }
  end
  
  def parseFile(_name)
    @fileName = _name
    File.open(@fileName, "r") { |file|
      @aFile = file
      file.each { |line|
        # add lines from file to @buff... after each addition yield as many
        # tokens as possible
        @buff << line
        # consume all the tokens from @buff that can be found... when no more
        # can be found analyze will return nil... so we'll get another line
        while aMatch = analyze
          # deliver one <token, lexeme pair> at a time to caller...
          # by convention a nil tokID is one about which the caller does not
          # care to hear...
          yield aMatch.rule.tokID, aMatch.lexeme if aMatch.rule.tokID
        end
      }
    }
    # @buff contains the earliest unmatched text... if @buff is not empty when
    # we finish with the file, this is an error
    if !@buff.empty?
      @errString = "#{@fileName}: error: unmatched text:\n#{@buff[0,[80, @buff.length].min]}"
      return false
    else
      @errStrng =  "#{@fileName}: no errors detected\n"
      return true
    end
  end 
  
  private
  def findMatch
    # return the UNIQUE token from @rules which matches the longest prefix of
    # @buff.  if no unique match can be identified, return nil
    maxLexeme, maxMatch = "", nil
    matchCount, rule2 = 0, nil
    @rules.each { |rule|
      # loop invariant:
      #  maxLexeme contains the longest matching prefix of @buff found so far,
      #  matchCount contains the number of rules that have matched maxLexeme,
      #  maxMatch contains the proposed return value
      #  rule2 contains a subsequent rule that also matches maxLexeme (if any)
      #
      # but... we have to avoid matching and instead keep looking if we make
      # it to the end of @buff with a match active (it may not yet be as long
      # as possible) OR if more than one match is still active.  If the end of
      # @buff is also the end of the file, then it's ok to match to the end
      #
      md = rule.re.match(@buff)
      if md && md.pre_match.empty?
        if md[0].length == @buff.length && !@aFile.eof?
          # @buff is potentially non-maximal and there is more file to parse
          return nil
          # either matching less than whole buffer OR at eof
        elsif md[0].length > maxLexeme.length
          # match is longer than any prior match => re-establish the invariant
          matchCount, rule2 = 1, nil
          maxLexeme, maxMatch = md[0], Match.new(rule,md[0])
        elsif  md[0].length == maxLexeme.length
          # a subsequent match of equal length has been found.
          # re-establish the invariant
          matchCount, rule2 = matchCount + 1, rule
        else
          # short match... skip
        end
      elsif md && !md.pre_match.empty?
        # rule did not match the start of @buff
        raise "match not at start of buffer #{@buff} : #{rule} : #{md} : #{md.pre_match}"
      else
        #rule did not match @buff
      end
    }
    if maxMatch && matchCount == 1
      #return an unambiguous match
      return maxMatch
    elsif maxMatch && matchCount > 1
      raise "ambiguous: #{maxLexeme} : #{maxMatch.rule} : #{rule2}"
      return nil
    else
      # no match was found
      return nil
    end
  end
  
  def analyze
    # find the longest matching prefix of the buffer... aMatch will contain the
    # rule that matched and the prefix/lexeme
    aMatch = findMatch
    
    #remove matched text from @buff
    @buff.slice!(0..aMatch.lexeme.length-1) if aMatch
    
    return aMatch
  end
  
end
