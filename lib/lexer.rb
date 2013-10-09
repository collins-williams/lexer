#!/usr/bin/env ruby -w

Rule = Struct.new :tokID, :re, :priority

Match = Struct.new :rule, :lexeme

=begin
=This class instantiates a file scanner based on rules it is given. 
addToken adds a rule described by a token identifiers, and a regular expression 
parseFile scans its file parameter, yeilding token idnetifiers and the strings that matched them
=end
class Lexer
  attr_reader :errString
  # keep a collection of regular expressions and values to return as token 
  # types
  # then match text to the longest substring yet seen
  def initialize
    @rules = []
    @buff = ""
  end
  
  def addToken (tokID, re, priority = 0)
    # prepend all regexp with \\A so that they only match at tbe beginning of a 
    # line
    reg_exp = 
    case re
    when String
      Regexp.new("\\A" + re)
    when Regexp
      Regexp.new("\\A" + re.source)
    else
      raise ArgumentError, "#{re.class.name} passed to addToken"
    end
    @rules << Rule.new(tokID, reg_exp, priority)
  end
  
  def show_rules
    @rules.each { |aRule|
      puts "#{aRule.tokID} #{aRule.re.source}, #{aRule.priority}"
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
      @errString =  "#{@fileName}: no errors detected\n"
      return true
    end
  end 
  
  private
  def findMatch
    # return the UNIQUE token from @rules which matches the longest prefix of
    # @buff.  if no unique match can be identified, return nil
    # if two or more rules match the same longest prefix decide based on priority
    # if two or more priorities match as well throw an error 
    matches = []
    @rules.each { |rule|
      # loop invariant:
      # matches contains all the rules that have matched the longest prefix of buffer
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
        elsif (matches.length == 0) || (md[0].length > matches[0].lexeme.length) 
          # match is longer than any prior match => re-establish the invariant
          matches = Array.new <<  Match.new(rule,md[0])
        elsif  md[0].length == matches[0].lexeme.length
          # a subsequent match of equal length has been found.
          # re-establish the invariant
          matches << Match.new(rule, md[0])
        else
          # short match... skip
        end
      end
    }
    #if matches has one element return it.  otherwise return the element 
    # of matches with the lowest priority
    if matches.length == 1
      return matches[0]
    elsif matches.empty?
      return nil
    else
      min_match = nil
      second_match = nil
      matches.each { |aMatch|
        #loop invariant:  min_match will contain a match with the lowest priority 
        # yet seen (or no match at all).  second_match will contain a rule that 
        # has the same priority as min_match (or no match at all)
        if min_match
          if min_match.rule.priority > aMatch.rule.priority
            min_match = aMatch
            second_match = nil
          elsif min_match.rule.priority == aMatch.rule.priority
            second_match = aMatch
          else
            # skip this one
          end
        else
          min_match = aMatch
          second_match = nil
        end 
      }
      # if the priority sucessfully broke the tie then return min_match; otherwise 
      # raise an exception
      if second_match
        raise "ambiguous: #{min_match.lexeme} : #{min_match.rule} : #{second_match.rule}"
      else
        return min_match
      end
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
