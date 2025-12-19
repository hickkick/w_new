require "cgi"

module TextHelper
  def nl2br(text)
    return "" if text.nil?

    CGI.escapeHTML(text.to_s).gsub("\n", "<br>")
  end
end
