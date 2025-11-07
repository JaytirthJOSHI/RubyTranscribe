class Transcription < ApplicationRecord
  # Active Storage: allows us to attach audio files to transcriptions
  has_one_attached :audio_file
  
  # Status can be: "pending", "processing", "completed", "failed"
  validates :status, inclusion: { in: %w[pending processing completed failed] }, allow_nil: true
end
