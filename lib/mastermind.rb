class Code

  PEGS = {
    Red: "R",
    Green: "G",
    Blue: "B",
    Yellow: "Y",
    Orange: "O",
    Purple: "P"
  }

  attr_reader :pegs

  def initialize(pegs)
    @pegs = pegs
  end

  def self.parse(color_string)
    color_string.upcase!
    color_string.each_char do |char|
      unless PEGS.values.any? { |code| char == code }
        raise ArgumentError
      end
    end
    Code.new(color_string.split(""))
  end

  def self.random
    peg_colors = PEGS.values
    random_code = []
    4.times do |i|
      random_code << peg_colors.sample
    end
    Code.new(random_code)
  end

  def [](pos)
    @pegs[pos]
  end

  def exact_matches(other_code)
    exact_matches = 0

    @pegs.each_with_index do |peg, i|
      if peg == other_code.pegs[i]
        exact_matches += 1
      end
    end

    exact_matches
  end

  def near_matches(other_code)
    other_code_color_counts = other_code.color_counts
    near_matches = 0

    self.color_counts.each do |color, count|
      next unless other_code_color_counts.has_key?(color)

      near_matches += [count, other_code_color_counts[color]].min
    end

    near_matches - exact_matches(other_code)
  end

  def color_counts
    color_counts = Hash.new(0)

    pegs.each { |color| color_counts[color] += 1 }

    color_counts
  end

  def ==(other)
    return false if other.class != Code
    @pegs == other.pegs
  end

  def to_s
    "[#{@pegs.join(", ")}]"
  end
end

class Game
  attr_reader :secret_code, :guess

  def initialize(code = nil)
    @secret_code = code || Code.random
  end

  def play
    10.times do |turn|
      get_guess
      break if won?
      display_matches(guess)
    end
    conclude
  end

  def won?
    guess == secret_code
  end

  def get_guess
    puts "Please input your guess (e.g. bryg)"
    @guess = Code.parse(gets.chomp)
  end

  def display_matches(code)
    puts "exact matches: #{secret_code.exact_matches(code)}"
    puts "near matches: #{secret_code.near_matches(code)}"
  end

  def conclude
    if secret_code == guess
      puts "Congratulations! You win."
    else
      puts "Sorry you lost, the code was #{secret_code}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end
