class CreateNicknames < ActiveRecord::Migration
  def change
    create_table :nicknames do |t|
      t.integer :column, :null => false
      t.string :word, :null => false

      t.timestamps
    end

    # Don't constraint with an index. They don't have to be unique.
    # Often they will be (as with the generic generator), but for some we might want to use a smaller subset and use duplicates to indicate frequency    
  end
end
