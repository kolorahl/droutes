module Droutes::Generators
  class DocumentationGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Parse application routes and create REST API documentation."
    def create_docs
      root = Droutes::Parser.new(Rails.application.routes.routes).parse
      root.children.each do |klass|
        content = class_doc(klass)
        create_file(".droutes/#{klass.controller}.html", page_wrapper(klass.controller.camelcase, content))
      end
    end

    protected

    def action_id(struct)
      "#{struct.controller}_#{struct.action}"
    end

    private

    def page_wrapper(title, content)
      <<HTML
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>#{title}</title>
        <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
    </head>

    <body>
#{content}

        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
        <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
    </body>
</html>
HTML
    end

    def class_doc(klass)
      <<DOC
<div class="container-fluid">
    <h1>#{klass.controller.capitalize} API</h1>
    <div id="#{klass.controller}" class="controller">
        <p class="summary">#{klass.docs.gsub(/\n/, " ")}</p>
#{klass.actions.collect {|action, struct| action_doc(struct)}.join("\n")}
    </div>
</div>
DOC
    end

    def action_doc(struct)
      <<DOC
<div id="#{action_id(struct)}" class="action panel panel-default">
    <div class="panel-heading">
        <h2 class="route panel-title"><code>#{struct.path}</code> <small>#{struct.verb}</small></h2>
    </div>
    <div class="comments panel-body">
#{comments_doc(struct.docs)}
    </div>
</div>
DOC
    end

    def comments_doc(doc)
      <<DOC
    <p class="summary">#{doc.summary}</p>
    <dl class="dl-horizontal params">
        #{doc.tags("param").collect{|param| "<dt>#{param.name}</dt><dd>[#{param.types.join("|")}] #{param.text}</dd>"}.join("\n")}
        #{(ret = doc.tags("return").first) and "<dt>[return]</dt><dd>#{ret.text}</dd>"}
    </dl>
DOC
    end
  end
end
