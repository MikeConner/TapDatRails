# CHARTER
#   Generate a random nickname from a list of words

# USAGE
#   nickname_generator in initializers defines named nickname generators as column ranges. The generator chooses words at
# random from each referenced column, and returns the concatenation as the nickname.
#
# NOTES AND WARNINGS
#   Checking for uniqueness of names in a location must happen externally; this could generate the same name multiple times
#
module NicknameGenerator
  @@nicknames = nil
  
  # Convenience constants
  # To add a new generator, name it here, define the corresponding column range, then load the data into Nicknames
  
  DEFAULT_GENERATOR = 'Generic'
  TOUGH_GENERATOR = 'Tough'
  
  # single_words_only guards against excessively long nicknames; if set, it will filter out multi-word terms
  def self.generate_nickname(generator_name = DEFAULT_GENERATOR, single_words_only = true)
    load_nicknames if @@nicknames.nil?
    
    raise ArgumentError.new('Unknown Nickname Generator') unless NICKNAME_GENERATORS.has_key?(generator_name)
      
    words = []
    for n in NICKNAME_GENERATORS[generator_name] do
      attempts = 0 # Make sure there's no infinite loop; it's possible there aren't any single words (data-dependent)
      begin
        next_name = @@nicknames[n][Random.rand(@@nicknames[n].count)] 
        attempts += 1
      end until !single_words_only or !next_name.include?(' ') or (attempts > 100)
      
      words.push(next_name)
    end
    
    words.join(' ')
  end
  
  # DB seeds calls this to generate a list of "tough guy" names without requiring any files
  def self.generate_tough_guy                  
    r1 = Random.rand(@@last_names.count)
    begin
      r2 = Random.rand(@@last_names.count)
    end until r2 != r1
      
    "#{@@first_names[Random.rand(@@first_names.count)]} #{@@last_names[r1]}#{@@last_names[r2]}"
  end

private
  @@first_names = ['Biff', 'Blake', 'Chuck', 'Slab', 'Beef', 'Dirk', 'Brock', 'Brent', 'Norris', 'Bram', 'Hank', 
                   'Denzel', 'Gunner', 'Harley', 'Heath', 'Kip', 'Kolt', 'Locke', 'Mick', 'Nick', 'Pierce', 'Rex',
                   'Rod', 'Slade', 'Spear', 'Stone', 'Wolfe', 'Wayne', 'Zane', 'Whip', 'Splint', 'Stag', 'Butch', 
                   'Randy', 'Savage', 'Fridge']
  @@last_names = ['Broad', 'Chest', 'Hack', 'Slam', 'Fist', 'Ham', 'Blast', 'Deep', 'Throb', 'Pec', 'Quad', 'Lats', 
                  'Muscle', 'Pound', 'Thump', 'Blow', 'Jizz', 'Thrust', 'Abs', 'Hair', 'Vander', 'Broth', 'Lift', 
                  'McFist', 'Manly', 'Gnash', 'Tooth', 'Man', 'Meat', 'Hard', 'Buff']

  def self.load_nicknames
    # Hash of arrays; 1 => ['adj1','adj2','adj3'], 2 => ['noun1','noun2','noun3']
    @@nicknames = Hash.new
    
    Nickname.all.each do |nickname|
      @@nicknames[nickname.column] = [] unless @@nicknames.has_key?(nickname.column)
      @@nicknames[nickname.column].push(nickname.word)
    end
  end
end
