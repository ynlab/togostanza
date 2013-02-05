FS.register_helper :adjust_iframe_height_script do
  <<-HTML.strip_heredoc.html_safe
    <script>$(function() {
      height = this.body.offsetHeight + 30;
      parent.postMessage(JSON.stringify({height: height, id: name}), "*");
    });</script>
  HTML
end
