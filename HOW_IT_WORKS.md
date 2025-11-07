# How RubyTranscribe Works - Programming Explanation

This document explains how the different parts of your Ruby on Rails application work together.

## 🏗️ The MVC Architecture

Rails follows the **Model-View-Controller (MVC)** pattern. Here's what each part does:

### **Model** (`app/models/transcription.rb`)
- Represents your **data** (a transcription record)
- Handles **validation** (making sure data is correct)
- Connects to the **database** to save/load data
- In our app: `Transcription` model stores title, status, text, and the audio file

### **View** (`app/views/transcriptions/*.html.erb`)
- The **HTML templates** that users see in their browser
- Uses **ERB** (Embedded Ruby) to mix Ruby code with HTML
- In our app: Forms for uploading, pages for viewing transcriptions

### **Controller** (`app/controllers/transcriptions_controller.rb`)
- The **middleman** between models and views
- Handles **HTTP requests** (GET, POST, etc.)
- Decides what to do when a user visits a URL
- In our app: Handles uploading files, saving transcriptions, showing results

---

## 🔄 How a Request Flows Through Your App

Let's trace what happens when someone uploads an audio file:

### 1. **User visits `/transcriptions/new`**
   - **Route** (`config/routes.rb`): `GET /transcriptions/new` → `transcriptions#new`
   - **Controller**: `TranscriptionsController#new` method runs
   - **View**: Renders `app/views/transcriptions/new.html.erb` (the upload form)
   - **Result**: User sees a form to upload audio

### 2. **User submits the form**
   - **Route**: `POST /transcriptions` → `transcriptions#create`
   - **Controller**: `TranscriptionsController#create` method runs
   - **What happens**:
     ```ruby
     # Create a new Transcription object with the form data
     @transcription = Transcription.new(transcription_params)
     @transcription.status = "pending"
     
     # Save it to the database
     if @transcription.save
       redirect_to @transcription  # Go to the show page
     else
       render :new  # Show errors if something went wrong
     end
     ```
   - **Model**: Validates the data and saves to database
   - **Active Storage**: Saves the audio file to disk/cloud
   - **Result**: New transcription record created, user redirected to view it

### 3. **User views the transcription**
   - **Route**: `GET /transcriptions/:id` → `transcriptions#show`
   - **Controller**: Finds the transcription by ID
   - **View**: Shows the transcription details and text
   - **Result**: User sees their uploaded file and transcription

---

## 📁 Key Files Explained

### `config/routes.rb`
```ruby
resources :transcriptions
```
This one line creates **7 RESTful routes**:
- `GET /transcriptions` → `index` (list all)
- `GET /transcriptions/new` → `new` (upload form)
- `POST /transcriptions` → `create` (save upload)
- `GET /transcriptions/:id` → `show` (view one)
- `GET /transcriptions/:id/edit` → `edit` (edit form)
- `PATCH /transcriptions/:id` → `update` (save edits)
- `DELETE /transcriptions/:id` → `destroy` (delete)

### `app/models/transcription.rb`
```ruby
class Transcription < ApplicationRecord
  has_one_attached :audio_file  # Active Storage for file uploads
  validates :status, inclusion: { in: %w[pending processing completed failed] }
end
```
- `has_one_attached` lets us attach files (Rails Active Storage feature)
- `validates` ensures status is one of the allowed values

### `app/controllers/transcriptions_controller.rb`
```ruby
def create
  @transcription = Transcription.new(transcription_params)
  @transcription.status = "pending"
  
  if @transcription.save
    redirect_to @transcription
  else
    render :new
  end
end

private

def transcription_params
  params.require(:transcription).permit(:title, :audio_file)
end
```
- `transcription_params` uses **strong parameters** (Rails security feature)
- Only allows `title` and `audio_file` - prevents malicious data
- `@transcription` (with `@`) makes it available to the view

---

## 🗄️ Database Structure

The `transcriptions` table has:
- `id` (auto-generated)
- `title` (string)
- `status` (string: "pending", "processing", "completed", "failed")
- `text` (text: the transcribed text)
- `created_at`, `updated_at` (timestamps)

Audio files are stored separately by Active Storage (not in the database).

---

## 🚀 Next Steps: Adding Transcription

Right now, the app can **upload and store** audio files, but doesn't actually transcribe them yet. To add transcription, you'll need to:

1. **Create a Background Job** (`app/jobs/transcription_job.rb`)
   - Jobs run in the background so the app doesn't freeze while processing
   - Use ActiveJob (built into Rails)

2. **Integrate a Transcription Service**
   - OpenAI Whisper API
   - Or another speech-to-text service
   - Or run Whisper locally

3. **Update the Controller**
   - After saving, trigger the background job
   - Job processes audio → saves text to database

4. **Add Status Updates**
   - Update status from "pending" → "processing" → "completed"
   - Show progress to users

---

## 💡 Ruby Concepts You're Learning

- **Classes**: `Transcription`, `TranscriptionsController`
- **Methods**: `def index`, `def create`, etc.
- **Instance Variables**: `@transcription` (available in views)
- **Conditionals**: `if @transcription.save`
- **Symbols**: `:title`, `:status` (like strings but immutable)
- **Arrays**: `%w[pending processing completed failed]`
- **Blocks**: `@transcriptions.each do |transcription|`
- **Rails Helpers**: `form_with`, `link_to`, `time_ago_in_words`

---

## 🧪 Try It Out!

1. Run `rails db:migrate` to create the database table
2. Visit `http://localhost:3000/transcriptions/new`
3. Upload an audio file
4. See it saved in the database!

Check the Rails console with `rails console` to see your data:
```ruby
Transcription.all  # See all transcriptions
Transcription.first  # See the first one
```

