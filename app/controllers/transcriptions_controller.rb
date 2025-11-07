class TranscriptionsController < ApplicationController
  # GET /transcriptions
  # Shows a list of all transcriptions
  def index
    @transcriptions = Transcription.order(created_at: :desc)
  end

  # GET /transcriptions/:id
  # Shows a single transcription with its text
  def show
    @transcription = Transcription.find(params[:id])
  end

  # GET /transcriptions/new
  # Shows the form to upload a new audio file
  def new
    @transcription = Transcription.new
  end

  # POST /transcriptions
  # Creates a new transcription from uploaded audio file
  def create
    @transcription = Transcription.new(transcription_params)
    @transcription.status = "pending" # Start as pending until we process it
    
    if @transcription.save
      # TODO: In the future, we'll trigger a background job here to process the audio
      # For now, we'll just save it
      redirect_to @transcription, notice: "Audio file uploaded! Transcription will start soon."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Strong parameters: Rails security feature - only allow these params
  def transcription_params
    params.require(:transcription).permit(:title, :audio_file)
  end
end
