require 'kramdown'
require 'fileutils'

CONTENT_DIR = 'content'
TEMPLATE_DIR = 'templates'
OUTPUT_DIR = 'output'
DEFAULT_TEMPLATE = 'default.html'

FileUtils.mkdir_p(OUTPUT_DIR)

def load_template(template_name = DEFAULT_TEMPLATE)
  template_path = File.join(TEMPLATE_DIR, template_name)
  unless File.exist?(template_path)
    puts "Error: Template #{template_path} not found!"
    exit 1
  end
  File.read(template_path)
end

def markdown_to_html(markdown_content)
  Kramdown::Document.new(markdown_content).to_html
end

def extract_title(markdown_content)
  title_match = markdown_content.match(/^#\s+(.+)$/)
  title_match ? title_match[1] : 'My Static Site'
end

def process_markdown_file(file_path)
  markdown_content = File.read(file_path)
  
  title = extract_title(markdown_content)
  
  html_content = markdown_to_html(markdown_content)
  
  template = load_template
  
  final_html = template
    .gsub('{{title}}', title)
    .gsub('{{content}}', html_content)
  
  filename = File.basename(file_path, '.md')
  output_filename = filename == 'index' ? 'index.html' : "#{filename}.html"
  output_path = File.join(OUTPUT_DIR, output_filename)
  
  File.write(output_path, final_html)
  
  puts "✓ Generated: #{output_path}"
  
  output_path
end

def generate_site
  puts "Starting site generation..."
  puts "-" * 50
  
  unless Dir.exist?(CONTENT_DIR)
    puts "Error: Content directory '#{CONTENT_DIR}' not found!"
    exit 1
  end
  
  markdown_files = Dir.glob(File.join(CONTENT_DIR, '*.md'))
  
  if markdown_files.empty?
    puts "No markdown files found in #{CONTENT_DIR}/"
    puts "Add some .md files to get started!"
    exit 1
  end
  
  puts "Found #{markdown_files.length} markdown file(s):"
  markdown_files.each { |f| puts "  - #{File.basename(f)}" }
  puts "-" * 50
  
  generated_files = []
  markdown_files.each do |file_path|
    generated_files << process_markdown_file(file_path)
  end
  
  puts "-" * 50
  puts "Site generation complete!"
  puts "Generated #{generated_files.length} HTML file(s) in #{OUTPUT_DIR}/"
  
  index_path = File.join(OUTPUT_DIR, 'index.html')
  if File.exist?(index_path)
    puts "\n✨ Your index.html is ready at: #{index_path}"
  end
end

if __FILE__ == $PROGRAM_NAME
  generate_site
end

