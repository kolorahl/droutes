module Droutes::Generators
  class DocGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def create_docs
      @root = Droutes::Parser.new(Rails.application.routes.routes).parse
      template("index.html", ".droutes/index.html")
      @root.children.each do |klass|
        @klass = klass
        template("controller.html", ".droutes/#{klass.controller}.html")
      end
    end

    protected

    def example_json(params)
      example_json = ''
      params.each do |param|
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
      example_json
    end
  end
end
