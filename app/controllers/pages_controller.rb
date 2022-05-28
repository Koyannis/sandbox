require 'nokogiri'
require 'open-uri'

class PagesController < ApplicationController

  before_action :wordbag
  $htmlyrics = "<div>Je m'baladais sur l'avenue le cœur ouvert à  l'inconnu</div>
  <div>J'avais envie de dire bonjour à  n'importe qui</div>
  <div>N'importe qui et ce fut toi, je t'ai dit n'importe quoi</div>
  <div>Il suffisait de te parler, pour t'apprivoiser</div>



  <div>Aux Champs-Elysées, aux Champs-Elysées</div>

  <div>Au soleil, sous la pluie, à  midi ou à  minuit</div>
  <div>Il y a tout ce que vous voulez aux Champs-Elysées</div>

  <div>Tu m'as dit J'ai rendez-vous dans un sous-sol avec des fous</div>
  <div>Qui vivent la guitare à  la main, du soir au matin</div>
"

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

    html = @html.css("div").each do |node|
      node.content = stringredact(node.content)
    end

    return html.to_html

  end



end
