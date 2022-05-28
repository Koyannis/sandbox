require 'nokogiri'
require 'open-uri'

class PagesController < ApplicationController

  before_action :wordbag

  def wordbag
    $htmlyrics = File.read("app/assets/paroles.txt")
    @html = Nokogiri::HTML.fragment($htmlyrics)
    @htmlpure = Nokogiri::HTML.fragment($htmlyrics)
    session[:lyrics] = @html.text
    session[:queries] ||= []

    @arrayofwords = session[:lyrics].split(/([a-zA-Z\u00C0-\u00FF]+|\s|\W|\w\W\w)/).map!(&:downcase).reject!(&:empty?)
  end

  def home
    @lyrics = session[:lyrics]
    @htmlredact = htmlredact()
    if params[:query].present?
      @mot = params[:query].downcase.strip
      session[:queries] |= [@mot]
    else
      @mot = "Proposez un mot !"
      @essai = ""
    end
    if params[:query].present?
      redirect_to root_path
    end
    if @htmlredact.include? @htmlpure.at('div').text
      flash[:notice] = "✨Bravo !✨"
    end
  end

  def reset
    reset_session
    redirect_to root_path
  end

private

# Récupere le fichier html et, pour chaque div, lance la censure
  def htmlredact
    htmlredacted = @html.css("div").each do |node|
      node.content = stringredact(node.content)
    end
    return htmlredacted.to_html
  end

# Divise une string en mots/ponctuaction/espaces et applique redact() sur chaque élément non proposé par l'utilisateur
# C'est le moteur du jeu ! Celui qui décide ce qui est caché ou non.
  def stringredact(string)
    redacted = string.split(/(<.+>|\w{3,}'\w{3,}|[a-zA-Z\u00C0-\u00FF]+|\s|\W|\w\W\w)/).reject!(&:empty?).map do |word|
      if session[:queries].include? word.downcase
        word
      else
        redact(word)
      end
    end
    redacted.join('')
  end

# Remplace chaque lettre d'un mot par un bloc. Uniquement si il s'agit d'alphanumérique
  def redact(word)
    redacted = ""
      word.each_char do |char|
        (char =~ /[[:alpha:]]/) ?  redacted += "█" :  redacted += char
      end
    return redacted
  end

end
