require "json"

class Hangman

  WORD_ARR = File.read("google-10000-english-no-swears.txt").split

  def initialize(chosen_word = "", guessed_word = "", guessed_letters = [], incorrect_guesses = 0, rounds_completed = 0, winner = nil)
    @chosen_word = chosen_word
    @guessed_word = guessed_word
    @guessed_letters = guessed_letters
    @incorrect_guesses = incorrect_guesses
    @rounds_completed = rounds_completed
    @winner = winner
  end

  def select_word
    while !(@chosen_word.length.between?(5,12))
      @chosen_word = WORD_ARR.sample.upcase
    end
  end

  def guess_letter
    selected_letter = nil
    while selected_letter.nil?
      puts "\nPlease select a letter!"
      selected_letter = gets.chomp.upcase
      if @guessed_letters.include?(selected_letter) || selected_letter.length != 1 || selected_letter != selected_letter[/[a-zA-Z]+/]
        puts "\nInput invalid. Please try again."
        selected_letter = nil
      else
        puts "\nInput accepted."
        @guessed_letters.push(selected_letter)
      end
    end
    selected_letter
  end

  def check_for_correct_guess(letter)
    if @chosen_word.include?(letter)
      return true
    end
    @incorrect_guesses += 1
    return false
  end

  def construct_guessed_word
    @guessed_word = ""
    @chosen_word.split("").each do |char|
      if @guessed_letters.include?(char)
        @guessed_word += char
      else
        @guessed_word += "_"
      end
    end
  end

  def check_for_winner
    if @guessed_word == @chosen_word
      @winner = "human"
    elsif @incorrect_guesses == 6
      @winner = "computer"
    end
  end

  def display_round_results
    @rounds_completed += 1
    puts "\nRound #{@rounds_completed}"
    puts "\nWord: #{@guessed_word}\n"
    puts "\nGuessed Letters: #{@guessed_letters}"
    puts "\nIncorrect Guesses: #{@incorrect_guesses} of 6"
    if !(@winner.nil?)
      if @winner == "human"
        puts "Congratulations! You have guessed the word '#{@chosen_word}' correctly!"
      else
        puts "Oh no! You failed to guess the word '#{@chosen_word}' correctly and the man has been hung!"
      end
      return true
    end
    return false
  end

  def to_json
    JSON.dump ({
      :chosen_word => @chosen_word,
      :guessed_word => @guessed_word,
      :guessed_letters => @guessed_letters,
      :incorrect_guesses => @incorrect_guesses,
      :rounds_completed => @rounds_completed,
      :winner => @winner
    })
  end

  def from_json(string)
    data = JSON.load string
    Hangman.new(data["chosen_word"], data["guessed_word"], data["guessed_letters"], data["incorrect_guesses"], data["rounds_completed"], data["winner"])
  end
end

def game_loop(game)
  game_finished = false
  while !game_finished
    puts "\nIf you would like to save your game, please type 'save'. \nOtherwise type anything else to continue playing! \nNote: Saving will overwrite your previous save."
    if gets.chomp.downcase == "save"
      puts "\nInput accepted."
      File.write "save.json", game.to_json
      puts "\nYour game has now been saved."
    end
    letter_guessed = game.guess_letter
    game.check_for_correct_guess(letter_guessed)
    game.construct_guessed_word
    game.check_for_winner
    game_finished = game.display_round_results
  end
end

puts (File.read "save.json").class
puts "\nWelcome to Hangman! Press any key to play! \nOr if you would like to load your save, please type 'load'!"
game = Hangman.new
input = gets.chomp.downcase
if input == "load"
  game = game.from_json(File.read "save.json")
else
  game.select_word
end
game.construct_guessed_word
game.display_round_results
game_loop(game)

