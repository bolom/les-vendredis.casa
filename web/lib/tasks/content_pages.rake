namespace :content_pages do
  desc "Import or update Rails content pages from the preserved HTML archive"
  task import: :environment do
    puts "content pages imported: #{ContentPages::Importer.new.call}"
  end
end
