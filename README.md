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
api_url: "http://api.dte.zboxapp.com/dte_messages"
log_file: "./test/tmp/carterdte_smtp_filter.log"
stand_alone: ""
```

## Postifx Configuration

```
 # master.cf
 [0.0.0.0]:30025 inet n  -       n       -       -  smtpd
     -o content_filter=
     -o local_recipient_maps=
     -o virtual_mailbox_maps=
     -o virtual_alias_maps=
     -o relay_recipient_maps=
     -o smtpd_restriction_classes=
     -o smtpd_delay_reject=no
     -o smtpd_client_restrictions=permit_mynetworks,reject
     -o smtpd_data_restrictions=
     -o smtpd_end_of_data_restrictions=
     -o smtpd_helo_restrictions=
     -o smtpd_milters=
     -o smtpd_sender_restrictions=
     -o smtpd_reject_unlisted_sender=no
     -o smtpd_relay_restrictions=
     -o smtpd_recipient_restrictions=permit_mynetworks,reject
     -o mynetworks_style=host
     -o mynetworks=127.0.0.0/8,[::1]/128
     -o strict_rfc821_envelopes=yes
     -o smtpd_error_sleep_time=0
     -o smtpd_soft_error_limit=1001
     -o smtpd_hard_error_limit=1000
     -o smtpd_client_connection_count_limit=0
     -o smtpd_client_connection_rate_limit=0
     -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks,no_address_mappings
     -o local_header_rewrite_clients=
     -o syslog_name=postfix/carterdte
 smtp-carterdte unix -      -       n       -       10  smtp
     -o smtp_data_done_timeout=1200
     -o smtp_send_xforward_command=yes
     -o disable_dns_lookups=yes
     -o max_use=20
```

```
 # main.cf
 content_filter = smtp-carterdte:[127.0.0.1]:30024
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/carterdte_smtp_filter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
