class CreateTranscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :transcriptions do |t|
      t.string :title
      t.string :status
      t.text :text

      t.timestamps
    end
  end
end
