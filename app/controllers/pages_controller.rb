require 'nokogiri'
require 'open-uri'

class PagesController < ApplicationController

  before_action :wordbag


  def wordbag
    session[:lyrics] = "Je m'baladais sur l'avenue le cœur ouvert à l'inconnu
    J'avais envie de dire bonjour à n'importe qui
    N'importe qui et ce fut toi, je t'ai dit n'importe quoi
    Il suffisait de te parler, pour t'apprivoiser
    Aux Champs-Elysées, aux Champs-Elysées
    Au soleil, sous la pluie, à midi ou à minuit
    Il y a tout ce que vous voulez aux Champs-Elysées
    Tu m'as dit J'ai rendez-vous dans un sous-sol avec des fous
    Qui vivent la guitare à la main, du soir au matin
    Alors je t'ai accompagnée, on a chanté, on a dansé
    Et l'on n'a même pas pensé à s'embrasser
    Aux Champs-Elysées, aux Champs-Elysées
    Au soleil, sous la pluie, à midi ou à minuit
    Il y a tout ce que vous voulez aux Champs-Elysées
    Hier soir, deux inconnus et ce matin sur l'avenue
    Deux amoureux tout étourdis par la longue nuit"

    session[:queries] ||= {}

    session[:counter] = WordsCounted.count(
      session[:lyrics]
    )

    session[:wordbag] = session[:counter].token_frequency

  end



  def home
    @lyrics = session[:lyrics]
    @wordbag = session[:wordbag]

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

end
