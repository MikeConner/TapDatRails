require 'csv'

namespace :db do
  desc "Load a Nickname table column from a file"
  task :load_nickname_file, [:filename, :column] => :environment do |t, args|
    if args.has_key?(:filename) and args.has_key?(:column)
      fname = File.basename(args[:filename], '.*') + '.csv'
      resolved_file = Rails.application.assets.find_asset(fname)
      
      column_num = Integer(args[:column])
      
      raise ArgumentError.new('File not found') if resolved_file.nil?
      raise ArgumentError.new('Invalid column number (> 0)') if column_num < 1
      
      Nickname.where(:column => column_num).delete_all
      
      CSV.foreach(resolved_file) do |line|
        Nickname.create(:column => column_num, :word => line[0].strip)
      end
    else
      puts "Please enter the name of a csv file (in the assets directory) and a column number (e.g., rake db:load_nickname_file['nouns', 2])"
    end
  end
end
