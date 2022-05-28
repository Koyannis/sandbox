require 'nokogiri'
require 'open-uri'

class PagesController < ApplicationController

  before_action :wordbag
  $htmlyrics = File.read("app/assets/paroles.txt")


  def wordbag
    @html = Nokogiri::HTML.fragment($htmlyrics)
    session[:lyrics] = @html.text
    session[:queries] ||= {}
    session[:counter] = WordsCounted.count(
      session[:lyrics]
    )
    session[:wordbag] = session[:counter].token_frequency
  end



  def home
    @lyrics = session[:lyrics]
    @wordbag = session[:wordbag]
    @htmlredact = htmlredact()
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

    if params[:query].present?
      redirect_to root_path
    end
  end


  def reset
    reset_session
    redirect_to root_path
  end

private

  def stringredact(string)
    redacted = string.split.map do |word|
      if session[:queries].include? word.downcase or word.size == 1
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

  def htmlredact
    html = Nokogiri::HTML.fragment($htmlyrics)

    html = @html.css("p").each do |node|
      node.content = stringredact(node.content)
    end

    return html.to_html

  end



end
