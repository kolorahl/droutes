droutes
=======

Pronounced like "drought", with an "s" on the end.

## What is it?

Rails has this nice rake task, `routes`, which is great for server developers to
check which routes go where, but it's not very appropriate for client
developers. Since I do a lot of work with client engineers I wanted a way to
generate client-friendly REST documentation based on the application routes. I
then added YARD into the mix, my personal favorite documentation tool, and came
up with `droutes`, or `documented routes`.

## How does it work?

Because it uses [YARD](http://yardoc.org/) as the underlying documentation
parser, anyone familiar with YARD can quickly and easily begin creating client
integration documentation.

Every controller is inspected by `droutes`, and a matching route config is
found. If you have a controller and action for something, but no route pointing
to it in `config/routes.rb`, then no documentation is generated for it.

YARD is used to parse the controller file. The output generated assumes that is
action uses the `@param` tag to reference a request parameter. Remember: in
Rails, request parameters may come from both the request body and the URL.

For example, if I wanted to document a request parameter called `id`, used in
the route `GET /posts/:id`, I would use YARD to capture it as so:

    @param [Integer] id the id of the post to view

## Using it

The `droutes` gem adds a rails generator instead of a rake task, as running the
operation from the generator ensures the Rails app environment is loaded and
that all the routing data is available. Without the routing data, the document
generator would not be able to gain information such as request method
(e.g. POST) or path (e.g. /posts/:id).

    rails g droutes:documentation

That's it. This will generate a folder `.droutes` that contains HTML
output. Each controller gets its own HTML file, and the index contains a sorted
list of all routing paths available.
