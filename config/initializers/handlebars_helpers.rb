FS.register_helper :adjust_iframe_height_script do
  <<-HTML.strip_heredoc.html_safe
    <script>$(function() { frameElement.height = frameElement.contentDocument.body.offsetHeight + 53; });</script>
  HTML
end
