# CarterdteSmtpFilter

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'carterdte_smtp_filter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carterdte_smtp_filter

## Configuration

```yaml
bind_address: 127.0.0.1
bind_port: 30024
return_host: 127.0.0.1
return_port: 30025
max_connections: 10
elasticsearch_host: 127.0.0.1
elasticsearch_port: 9200
api_user: pbruna@example.com
api_password: 123456
api_host: "api.dte.zboxapp.com"
log_file: "./test/tmp/carterdte_smtp_filter.log"
stand_alone: ""
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/carterdte_smtp_filter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
