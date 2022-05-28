require 'nokogiri'
require 'open-uri'

class PagesController < ApplicationController

  before_action :wordbag



  def wordbag
    $htmlyrics = File.read("app/assets/paroles.txt")
    @html = Nokogiri::HTML.fragment($htmlyrics)
    session[:lyrics] = @html.text
    session[:queries] ||= {}
    session[:counter] = WordsCounted.count(
      session[:lyrics]
    )
    session[:wordbag] = session[:counter].token_frequency
    @arrayofwords = session[:lyrics].split(/([a-zA-Z\u00C0-\u00FF]+|\s|\W|\w\W\w)/).reject!(&:empty?)
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

def htmlredact
  htmlredacted = @html.css("div").each do |node|
    node.content = stringredact(node.content)
  end

  return htmlredacted.to_html

end

  def stringredact(string)
    redacted = string.split(/([a-zA-Z\u00C0-\u00FF]+|\s|\W|\w\W\w)/).reject!(&:empty?).map do |word|
      if session[:queries].include? word.downcase
        word
      else
        redact(word)
      end
    end
    redacted.join('')
  end

  def redact(word)
    redacted = ""
      word.each_char do |char|
        (char =~ /[[:alpha:]]/) ?  redacted += "█" :  redacted += char
      end
    return redacted
  end





end
