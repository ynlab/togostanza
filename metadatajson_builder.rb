require 'json'

def execute
  file = File.read('ontology/metadata.json')
  hash = JSON.parse(file)
  stanzas = hash["stanza:stanzas"]
  stanzas.each do |stanza|
    stanza_name =  stanza['@id'].split('/').last + '_stanza'
    File.open("#{stanza_name}/metadata.json", 'w') {|file| file.puts JSON.pretty_generate(stanza) }
  end
end
