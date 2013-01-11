class StanzaGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def generate_files
    template 'stanza.rb.erb',    "app/stanza/#{file_name}_stanza.rb"
    template 'template.hbs.erb', "app/stanza/templates/#{file_name}_stanza.hbs"
  end
end
