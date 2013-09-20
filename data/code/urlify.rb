def urlify(str)

  url_str = ""
  url_str = String.new(str) if str

  url_str.gsub!(/[\'\"\?]/, '') # remove apostrophes, quote marks and question marks
  url_str.gsub!(/\W+/, ' ') # all other non-word chars to spaces
                        # handle any non-ASCII chars
  url_str.strip!            # 
  url_str.downcase!         #
  url_str.gsub!(/\ +/, '-') # spaces to hyphens as separator
  return url_str        
end