require 'sinatra'
require 'sinatra/reloader' if development?
require 'kramdown'

require 'fileutils'
require 'json'

set :public_folder, 'public'
set :views, 'views'


FileUtils.mkdir_p('tmp')
FileUtils.mkdir_p('output')

FileUtils.mkdir_p('content')

get '/' do
    erb :index
end

post '/upload' do
    if params[:file] && params[:file][:filename]
        filename = params[:file][:filename]
        file = params[:file][:tempfile]
        filepath = File.join('content', filename)
        
        File.open(filepath, 'wb') do |f|
            f.write(file.read)
        end
        
        html_file = generate_html(filepath)
        content_type :json
        { 
            success: true,
            message: 'File uploaded successfully and HTML was made!!!',
            html_file: html_file,
            download_url: "/download/#{File.basename(html_file)}"
        }.to_json

    else
        status 400
        content_type :json
        {
            success: false,
            message: 'No file uploaded/smth broke'
        }.to_json
    end
end

get '/download/:filename' do
    filename = params[:filename]
    filepath = File.join('output', filename)
    if File.exist?(filepath)
        send_file filepath, type: 'text/html', disposition: 'attachment'

    else
        status 404 #take me back to 505 lmao 
        "file not found" 
    end
end

def generate_html(markdown_file)
    markdown_content = File.read(markdown_file)
    title = extract_title(markdown_content)
    html_content = markdown_to_html(markdown_content)
    template = File.read('templates/default.html')

    final_html = template
        .gsub('{{title}}', title)
        .gsub('{{content}}', html_content)
    
    filename = File.basename(markdown_file, '.md')
    output_filename = filename == 'index' ? 'index.html' : "#{filename}.html"
    output_path = File.join('output', output_filename)
    File.write(output_path, final_html)
    output_path
end


def markdown_to_html(markdown_content)
    Kramdown::Document.new(markdown_content).to_html
end

def extract_title(markdown_content)
    title_match = markdown_content.match(/^#\s+(.+)$/)
    title_match ? title_match[1] : 'My Static Site'
end

post '/generate' do
    markdown_files = Dir.glob('content/*.md')
    
    if markdown_files.empty?
        status 400
        content_type :json
        { success: false, message: "No markdown files found" }.to_json
        return
    end
    
    generated_files = []
    markdown_files.each do |file_path|
        html_file = generate_html(file_path)
        generated_files << File.basename(html_file)
    end
    
    content_type :json
    {
        success: true,
        message: "Generated #{generated_files.length} file(s) successfully",
        files: generated_files
    }.to_json
end

get '/files' do
    files = Dir.glob('output/*.html').map { |f| File.basename(f) }
    content_type :json
    { files: files }.to_json
end

get '/' do
    erb :index
end