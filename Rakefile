require "html-proofer"
require "nokogiri"

SITE_DIR = "./_site"
PUBLIC_IMAGES = "./public/images"

task default: :test

task :build do
  sh "bundle exec jekyll build"
end

# Check 1: no broken internal links
task :check_links => :build do
  puts "\n== Checking internal links =="
  HTMLProofer.check_directory(SITE_DIR, {
    disable_external: true,
    checks: ["Links"],
    ignore_files: [/feed\.xml/, /sitemap\.xml/],
    ignore_urls: [/lesvendredis\.casa/, /wa\.me/, /buttondown\.com/, /google/, /fonts\.gstatic/],
    enforce_https: false,
  }).run
end

# Check 2: all img src and og:image point to files that exist
task :check_images => :build do
  puts "\n== Checking image files exist =="
  errors = []

  Dir.glob("#{SITE_DIR}/**/*.html").each do |file|
    doc = Nokogiri::HTML(File.read(file))
    page = file.sub(SITE_DIR, "")

    # <img src="..."> — skip empty src (lightbox JS placeholder)
    doc.css("img[src]").each do |img|
      src = img["src"]
      next if src.nil? || src.empty?
      next if src.start_with?("http", "data:")
      local = File.join(SITE_DIR, src.split("?").first)
      errors << "#{page}: missing img src #{src}" unless File.exist?(local)
    end

    # og:image
    doc.css('meta[property="og:image"]').each do |meta|
      content = meta["content"]
      next if content.nil? || content.empty?
      next unless content.include?("lesvendredis.casa")
      path = content.sub("https://lesvendredis.casa", "")
      local = File.join(SITE_DIR, path)
      errors << "#{page}: missing og:image #{content}" unless File.exist?(local)
    end

    # double-slash paths
    doc.css("img[src]").each do |img|
      src = img["src"].to_s
      errors << "#{page}: double-slash in src #{src}" if src.include?("//public")
    end

    # wrong domain in og:image
    doc.css('meta[property="og:image"]').each do |meta|
      content = meta["content"].to_s
      errors << "#{page}: wrong domain in og:image #{content}" if content.include?("les-vendredis.casa")
    end
  end

  if errors.any?
    errors.each { |e| puts "  FAIL: #{e}" }
    abort "\n#{errors.size} image error(s) found."
  else
    puts "  All images OK (#{Dir.glob("#{SITE_DIR}/**/*.html").size} pages checked)"
  end
end

task test: [:check_links, :check_images] do
  puts "\nAll checks passed."
end
