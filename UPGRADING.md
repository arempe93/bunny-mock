Upgrading BunnyMock
===================

## Upgrading to >= 1.4.0

#### Changes to `Queue#pop` api

The implmentation of `BunnyMock::Queue#pop` has changed to support the same return value as `Bunny`. The old functionality is still enabled by default. To use the new functionality that matches `Bunny`, place the following in your `spec_helper.rb` or etc.

```ruby
BunnyMock.use_bunny_queue_pop_api = true
```

## Upgrading to >= 1.2.0

#### Changes `has_binding?` to `routes_to?` in `BunnyMock::Exchange`

The `has_binding?` helper has been name changed to `routes_to?`. For now, an alias exists for `has_binding?`, but this may be deprecated in version 2.

#### Changes to use `Bunny` exceptions, instead of custom

Now all exceptions thrown will be the original `Bunny` exceptions
