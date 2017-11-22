# Dwarf

![Status](https://img.shields.io/badge/status-WIP-yellow.svg)
[![Tag](https://img.shields.io/github/tag/icyleaf/dwarf.svg)](https://github.com/icyleaf/dwarf/blob/master/CHANGELOG.md)
[![Dependency Status](https://shards.rocks/badge/github/icyleaf/dwarf/status.svg)](https://shards.rocks/github/icyleaf/dwarf)
[![devDependency Status](https://shards.rocks/badge/github/icyleaf/dwarf/dev_status.svg)](https://shards.rocks/github/icyleaf/dwarf)
[![Build Status](https://img.shields.io/circleci/project/github/icyleaf/dwarf/master.svg?style=flat)](https://circleci.com/gh/icyleaf/dwarf)
[![License](https://img.shields.io/github/license/icyleaf/dwarf.svg)](https://github.com/icyleaf/dwarf/blob/master/LICENSE)

General HTTP Authentication Framework for Crystal, based on [HTTP Server Handler](https://crystal-lang.org/api/0.23.1/HTTP/Handler.html) means it compatibles with most of web frameworks which is could add http server handler(middlewave), such like kemal, router.cr, raze etc. Inspired from the awesome Ruby's [warden](https://github.com/hassox/warden) gem.

## Supperted Frameworks

- [x] [HTTP Server](https://crystal-lang.org/docs/overview/http_server.html)
- [x] [router.cr](https://github.com/tbrand/router.cr)
- [x] [kemal](https://github.com/kemalcr/kemal)
- [x] [raze](https://github.com/samueleaton/raze)
- [x] [amber](https://github.com/amberframework/amber)

## Ignored Frameworks

- [lucky](https://github.com/luckyframework/web) - Can not support, [hard code](https://github.com/luckyframework/web/blob/f3ace765555ea75c29b40bc4cb4f8747b4ed82c9/src/server.cr#L14) handlers.

## Usage

```crystal
require "dwarf"
# Load the framework plugin appropriate to your project, require one at least.
#
# Common request, support built-in http server, raze
# require "dwarf/services/common"
# Kemal framework
# require "dwarf/services/kemal"
# Amber framework
# require "dwarf/services/kemal"

# Create a password strategy
class PasswordStrategy < Dwarf::Strategies::Base
  def valid?
    params["username"]? && params["password"]?
  end

  def authenticate!
    if params["username"] == "dwarf" && params["password"] == "foobar"
      user = JSON.parse({ "name" => params["username"] }.to_json)
      success!(user)
    else
      fail!
    end
  end
end

# Instance dwarf manager(handler)
dwarf_manager = Dwarf::Manager.new do |config|
  config.register_strategy("password", PasswordStrategy.new)
  config.default_strategies(strategies: ["password"])
end

# Then add `dwarf_manager.handler` to framework's handlers
```

Here has some [examples](https://github.com/icyleaf/dwarf/tree/master/examples) for usages.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  dwarf:
    github: icyleaf/dwarf
```

## TODO

- [ ] Stores(session)
- [ ] Callbacks

## Contributing

1. Fork it ( https://github.com/icyleaf/dwarf/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [icyleaf](https://github.com/icyleaf) - creator, maintainer
