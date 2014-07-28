module Droutes::Generators
  class DocumentationGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Parse application routes and create REST API documentation."
    def create_docs
      @root = Droutes::Parser.new(Rails.application.routes.routes).parse
      @root.children.each do |klass|
        next if klass.paths.empty?
        content = class_doc(klass)
        create_file(".droutes/#{klass.controller}.html", page_wrapper(klass.controller.camelcase, content))
      end
      create_file(".droutes/index.html", index_page)
    end

    protected

    def action_id(struct)
      "#{struct.controller}_#{struct.action}"
    end

    private

    def index_page
      <<HTML
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Route Index</title>
        <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
    </head>

    <body>
      <p>All available routes (sorted by name):</p>
      <ul>
#{@root.children.collect do |node|
    node.paths.collect do |path, actions|
      struct = actions.values.first
      "        <li><a href=\"#{struct.controller}.html##{action_id(struct)}\">#{path}</a></li>"
    end.join("\n")
  end.join("")}
      </ul>
    </body>
</html>
HTML
    end

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
      structs = []
      klass.paths.keys.sort.each {|path| structs += klass.paths[path].values}
      <<DOC
<div class="container-fluid">
    <h1>#{klass.controller} API</h1>
    <div id="#{klass.controller}" class="controller">
        <p class="summary">#{klass.docs.gsub(/\n/, " ")}</p>
        <div class="toc">
          <h3>Routes</h3>
          <dl>
#{structs.collect do |struct|
    "            <dt><a href=\"##{action_id(struct)}\">#{struct.verb} #{struct.path}</a></dt><dd>#{struct.docs.summary}</dd>"
  end.join("\n")}
          </dl>
        </div>
        <div class="routes">
          <h3>Documentation</h3>
#{structs.collect {|struct| action_doc(struct)}.join("\n")}
        </div>
    </div>
</div>
DOC
    end

    def action_doc(struct)
      <<DOC
<div id="#{action_id(struct)}" class="action panel panel-default">
    <div class="panel-heading">
        <h2 class="route panel-title"><code>#{struct.verb} #{struct.path}</code> <small>#{struct.action}</small></h2>
    </div>
    <div class="comments panel-body">
#{comments_doc(struct.docs)}
    </div>
</div>
DOC
    end

    def comments_doc(doc)
      params_dl = '<dl class="dl-horizontal params">'
      example_json = ''
      doc.tags("param").each do |param|
        params_dl += "    <dt>#{param.name}</dt><dd>[#{param.types.join('|')}] #{param.text}</dd>"
        eg_param = param.types.first
        eg_text = if ["String", "Symbol"].include?(eg_param)
                    '"some string"'
                  elsif ["Fixnum", "Integer", "Int"].include?(eg_param)
                    rand(100)
                  elsif ["Float", "Double", "Numeric"].include?(eg_param)
                    (rand * 100.0).round(2)
                  elsif eg_param == "Hash"
                    '{}'
                  elsif eg_param == "Arrray"
                    '[]'
                  end
        example_json += "\n    \"#{param.name}\": #{eg_text},"
      end
      unless example_json.blank?
        example_json = "<p>Example JSON Body</p><pre><code>{#{example_json}\n}</code></pre>"
      end
      <<DOC
    <p class="summary">#{doc.summary}</p>
    <dl class="dl-horizontal params">
        #{params_dl}
        #{(ret = doc.tags("return").first) and "<dt>[return]</dt><dd>#{ret.text}</dd>"}
    </dl>
    #{example_json}
DOC
    end
  end
end
