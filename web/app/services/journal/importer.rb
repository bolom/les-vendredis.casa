require "yaml"

module Journal
  class Importer
    CONTENT_ROOT = Rails.root.join("db/content/journal")

    def call
      imported = 0

      JournalPost.transaction do
        source_files.each do |path|
          attributes = parse(path)
          JournalPost.find_or_initialize_by(locale: attributes.fetch(:locale), slug: attributes.fetch(:slug))
            .update!(attributes)
          imported += 1
        end
      end

      imported
    end

    private

    def source_files
      Dir[CONTENT_ROOT.join("{en,fr}/*.md")].sort
    end

    def parse(path)
      source = File.read(path)
      _opening, front_matter, body = source.split("---", 3)
      metadata = YAML.safe_load(front_matter, permitted_classes: [ Date ], aliases: true)
      locale = Pathname(path).dirname.basename.to_s

      {
        title: metadata.fetch("title"),
        slug: slug_for(metadata, path),
        locale: locale,
        translation_key: metadata["translation_key"],
        tag: metadata["tag"],
        image_path: metadata["image"],
        image_alt: metadata["image_alt"],
        summary: metadata["summary"],
        description: metadata["description"],
        body_markdown: body.strip,
        published_on: metadata.fetch("date").to_date,
        published: true
      }
    end

    def slug_for(metadata, path)
      return metadata["permalink"].split("/").reject(&:empty?).last if metadata["permalink"].present?

      File.basename(path, ".md").sub(/\A\d{4}-\d{2}-\d{2}-/, "").sub(/-fr\z/, "")
    end
  end
end
