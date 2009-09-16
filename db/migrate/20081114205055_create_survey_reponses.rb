class CreateSurveyReponses < ActiveRecord::Migration
  def self.up
    create_table :survey_responses do |t|
      t.string :survey_name
      t.column :responses, :blob
    end
  end
  
  def self.down
    drop_table :survey_responses
  end
end
