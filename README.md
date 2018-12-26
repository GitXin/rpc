# Rpc

Remote Procedure Call among rails projects.

* expose class methods to some other projects by declaring, instead of writing complex controller/action codes

* support active-record query chain methods by default

* using white ips & signature verify to ensure security

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rpc', github: 'GitXin/rpc', branch: :master
```

And then execute:

```
$ bundle
```

## Usage

Add `rpc.rb` into `config/initializers/`

### Active current project to be rpc

```ruby
require 'rpc/api'
```

This will generate a route and an controller#action for rpc.

### Set white ips for current project

The default white ips are `['127.0.0.1', '::1']`, so that we can access local projects when develop.

Just add another ips like below:

```ruby
module Rpc
  IPS = ['ip.ip.ip.ip']
end
```

### Set unique digest key

The default digest key is 'reserve', you can override within your unique digest key to keep safe:

```ruby
module Rpc
  DIGEST_KEY = 'unique'
end
```

### Permit certain methods to be accessible

There are some default methods can be accessible througth rpc, so that we can use active-record easily, those methods can be found at `lib/rpc/permit_methods.rb`.

And maybe you want to expose some custom methods, just define the constant named `RPC_METHODS`, then those methods can be permitted to access.

```ruby
Example::RPC_METHODS = [:test_method]
```

### Use models from another project

Declare antoher project's basic info, such as url, models to be rpc.

```ruby
module Rpc
  module Server
    BASE_URL = 'http://server.example.com'

    class Example < Rpc::Base
    end
  end
end
```

Then we can use rpc like below:

```ruby
# default active-record syntax
Rpc::Server::Example.first
# => #<Rpc::Server::Example:0x00007fa6a1d6e300 @attributes={"id"=>1, "name"=>"justtest"}>

# default active-record syntax
Rpc::Server::Example.where(name: 'rpc').count
# => 1

# permitted to be access by last chapter's definition
Rpc::Server::Example.test_method
# => value return by test_methods from remote server
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/GitXin/rpc](https://github.com/GitXin/rpc).
