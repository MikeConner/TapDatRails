module NicknameGenerator
  @@nicknames = nil
  
  def self.generate_nickname
    load_nicknames if @@nicknames.nil?
    
    words = []
    for n in 1..@@nicknames.keys.count do
      words.push(@@nicknames[n][Random.rand(@@nicknames[n].count)])
    end
    
    words.join(' ')
  end
  
private
  def self.load_nicknames
    # Hash of arrays; 1 => ['adj1','adj2','adj3'], 2 => ['noun1','noun2','noun3']
    @@nicknames = Hash.new
    
    Nickname.all.each do |nickname|
      @@nicknames[nickname.column] = [] unless @@nicknames.has_key?(nickname.column)
      @@nicknames[nickname.column].push(nickname.word)
    end
  end
end