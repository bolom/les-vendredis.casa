namespace :journal do
  desc "Import or update journal posts from the Rails-owned Markdown archive"
  task import: :environment do
    puts "journal posts imported: #{Journal::Importer.new.call}"
  end
end
