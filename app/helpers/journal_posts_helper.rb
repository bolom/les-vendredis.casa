module JournalPostsHelper
  def render_markdown(markdown)
    sanitize(
      Kramdown::Document.new(markdown, input: "kramdown", hard_wrap: false).to_html,
      tags: %w[p br h2 h3 h4 ul ol li blockquote strong em a code pre hr img figure figcaption],
      attributes: %w[href title src alt loading]
    )
  end
end
