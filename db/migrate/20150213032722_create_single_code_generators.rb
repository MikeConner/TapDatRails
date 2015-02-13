class CreateSingleCodeGenerators < ActiveRecord::Migration
  def change
    create_table :single_code_generators do |t|
      t.references :currency
      t.string :code, :null => false, :limit => 32
      t.date :start_date
      t.date :end_date
      t.integer :value, :null => false

      t.timestamps
    end
    
    # We determine the currency from the code, so they have to be unique across currencies
    add_index :single_code_generators, :code, :unique => true
  end
end
