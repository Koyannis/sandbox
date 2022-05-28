class PagesController < ApplicationController

  before_action :wordbag

  def wordbag
    session[:lyrics] = "Bonjour bonsoir bonjour comment allez vous ?"

    session[:queries] ||= {}

    session[:counter] = WordsCounted.count(
      session[:lyrics]
    )

    session[:wordbag] = session[:counter].token_frequency

  end



  def home
    @lyrics = session[:lyrics]
    @wordbag = session[:wordbag]
    @indexedlyrics = []
    @lyrics.scan(/\w+(?:'\w+)*/) {|word| @indexedlyrics << [word, @wordbag.find_index{ |k,_| k == word.downcase}]}
    @indexedlyricshash = Hash[@indexedlyrics.flatten.each_slice(2).to_a]

    @wordbag = Hash[@wordbag.flatten.each_slice(2).to_a]

    if params[:query].present?
      @mot = params[:query].downcase
      @frequence = @wordbag[@mot.downcase]
      @frequence ||= 0
      session[:queries][@mot] = @frequence
    else
      @mot = "Proposez un mot !"
      @essai = ""
    end

    @redactedtext = stringredact(session[:lyrics])

  end

private

  def stringredact(string)
    redacted = string.split.map do |word|
      if session[:queries].include? word.downcase
        word
      else
        redact(word)
      end
    end
    redacted.join(' ')
  end

  def redact(word)
    redacted = ""
      word.each_char do |char|
        (char =~ /[[:alpha:]]/) ?  redacted += "█" :  redacted += char
      end
    return redacted
  end

end
