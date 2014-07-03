module Droutes::Generators
  class DocumentationGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Parse application routes and create REST API documentation."
    def create_docs
      root = Droutes::Parser.new(Rails.application.routes.routes).parse
      root.children.each do |klass|
        create_file(".droutes/#{klass.controller}.html", class_doc(klass))
      end
    end

    private

    def class_doc(klass)
      <<DOC
<div class="docs">
    <div id="#{klass.controller}" class="controller">
#{klass.actions.collect {|action, struct| action_doc(struct)}.join("\n")}
    </div>
</div>
DOC
    end

    def action_doc(struct)
      <<DOC
<div id="#{struct.controller}_#{struct.action}" class="action doc">
    <h2 class="route">#{struct.verb} #{struct.path}</h2>
    <div class="comments">
#{comments_doc(struct.docs)}
    </div>
</div>
DOC
    end

    def comments_doc(doc)
      <<DOC
    <p class="summary">#{doc.summary}</p>
    <ul class="params">
        #{doc.tags("param").collect{|param| "<li class=\"param\"><span class=\"name\">#{param.name}</span> <span class=\"desc\">#{param.text}</span></li>"}.join("\n")}
        #{(ret = doc.tags("return").first) and "<li class=\"return\"><span class=\"name\">return</span> <span class=\"desc\">#{ret.text}</span></li>"}
    </ul>
DOC
    end
  end
end
