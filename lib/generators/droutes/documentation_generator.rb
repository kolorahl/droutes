module Droutes::Generators
  class DocumentationGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Parse application routes and create REST API documentation."
    def create_docs
      structs = Droutes::Parser.new(Rails.application.routes.routes).parse
      puts "#{structs}"
      structs.each do |struct|
        create_file(".droutes/#{struct.controller}.html", action_doc(struct))
      end
    end

    private

    def action_doc(struct)
      <<DOC
<div id="#{struct.controller}_#{struct.action}" class="doc">
    <h2>#{struct.verb} #{struct.path}</h2>
    <div class="comments">
#{comments_doc(struct.docs)}
    </div>
</div>
DOC
    end

    def comments_doc(doc)
      docf = "<p class=\"summary\">#{doc.summary}</p>"
      docf += "<ul class=\"params\">"
      doc.tags("param").each do |param|
        docf += "<li class=\"param\"><span class=\"name\">#{param.name}</span> <span class=\"desc\">#{param.text}</span></li>"
      end
      ret = doc.tags("return").first
      if ret
        docf += "<li class=\"return\"><span class=\"name\">return</span> <span class=\"desc\">#{ret.text}</span></li>"
      end
      docf += "</ul>"
      docf
    end
  end
end
