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
    @lyrics.scan(/\w+(?:'\w+)*/) {|word| @indexedlyrics << [word, @wordbag.find_index{ |k,v| k == word.downcase}]}
    @redactedtext = stringredact(session[:lyrics])
    @wordbag = Hash[@wordbag.flatten.each_slice(2).to_a]
    if params[:query].present?
      @mot = params[:query].downcase
      @essai = @wordbag[@mot]
      @essai ||= 0
      session[:queries][@mot] = @essai

    else
      @mot = "Proposez un mot !"
      @essai = ""
    end

  end

private

  def stringredact(string)
    string.split.map{ |word| redact(word)}.join(' ')
  end

  def redact(word)
    redacted = ""
      word.each_char do |char|
        (char =~ /[[:alpha:]]/) ?  redacted += "█" :  redacted += char
      end
    return redacted
  end

end
