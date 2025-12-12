class CreateAnalyses < ActiveRecord::Migration[7.2]
  def change
    create_table :analyses do |t|
      t.references :chat_session, null: false, foreign_key: true
      t.text :root_cause
      t.text :insights
      t.text :summary
      t.text :actions

      t.timestamps
    end
  end
end
