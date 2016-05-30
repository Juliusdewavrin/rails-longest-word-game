require 'open-uri'
require 'json'

class LongestWordController < ApplicationController

  def game
    @grid = generate_grid(9)
    @start_time = Time.now.to_i
    session[:start_time] = @start_time
    session[:grid] = @grid
    # session est un hash global a tout le projet rails dans lequel stocker ce quon veut
  end

  def score
    @attempt = params[:attempt]
    @end_time = Time.now.to_i
    @result = run_game(@attempt, session[:grid], session[:start_time], @end_time)
  end

  private

  def generate_grid(grid_size)
  Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])
    result
  end

  def included?(guess, grid)
    the_grid = grid.clone
    guess.chars.each do |letter|
      the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
    end
    grid.size == guess.size + the_grid.size
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
    # score = attempt.size * 1
    return score
  end



  def score_and_message(attempt, translation, grid, time)
    if translation
      if included?(attempt.upcase, grid)
        score = compute_score(attempt , time)
        [score, "well done"]
      else
        [0, "not in the grid"]
      end
    else
      [0, "not an english word"]
    end
  end


  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

end

# grid = generate_grid(9)
# puts grid.join(" ")
