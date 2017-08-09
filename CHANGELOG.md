## Next release

_Add contribution here_

## v1.7.0

* [#32](https://github.com/arempe93/bunny-mock/pull/32): Implement reject functionality - [@binaryberry](https://github.com/binaryberry)
* [#31](https://github.com/arempe93/bunny-mock/pull/31): Add `generate_consumer_tag` to `BunnyMock::Channel` - [@Jakenberg](https://github.com/Jakenberg)
* [#23](https://github.com/arempe93/bunny-mock/pull/23): Fix queue bind returning an array instead of self - [@fugufish](https://github.com/fugufish)

## v1.6.0

* [#27](https://github.com/arempe93/bunny-mock/pull/27): Allow `Session#create_channel` to accept additional args - [@eebs](https://github.com/eebs)
* [#20](https://github.com/arempe93/bunny-mock/pull/30): Adds implementation of `ack` and `nack` - [@dwhenry](https://github.com/dwhenry)

## v1.5.0

* [#20](https://github.com/arempe93/bunny-mock/pull/20): Adds implementation of `Queue#subscribe` - [@baelter](https://github.com/baelter)

## v1.4.0

* [#19](https://github.com/arempe93/bunny-mock/pull/12): Adds support for JRuby with Bunny 1.7.0 - [@TimothyMDean](https://github.com/TimothyMDean)
* [#16](https://github.com/arempe93/bunny-mock/issues/16): Fixes wildcard implementation for topic exchanges - [@arempe93](https://github.com/arempe93)
* [#15](https://github.com/arempe93/bunny-mock/issues/15): Changes to `Queue#pop` api to match Bunny - [@arempe93](https://github.com/arempe93)

## v1.3.0

* [#12](https://github.com/arempe93/bunny-mock/pull/12): Adds `basic_publish` functionality to `Channel` - [@podung](https://github.com/podung)
* [#13](https://github.com/arempe93/bunny-mock/pull/13): Add `confirm_select` method stub - [@baelter](https://github.com/baelter)

## v1.2.2

* [#6](https://github.com/arempe93/bunny-mock/pull/6): Adds more status methods to `Session` - [@syndbg](https://github.com/syndbg)

## v1.2.1

* [#5](https://github.com/arempe93/bunny-mock/pull/5): Fixes `routing_key` being modified when delivering in a topic exchange - [@austinmoore](https://github.com/austinmoore)

## v1.2.0

* Adds `with_channel` functionality to `BunnyMock::Session`
* Renames `BunnyMock::Exchange#has_binding?` to `BunnyMock::Exchange#routes_to?`
* Adds `Bunny` as a dependency to use its exceptions

## v1.1.0

* Moves queue and exchange storage to `BunnyMock::Session`
* Adds `queue_exists?` and `exchange_exists?` methods to `BunnyMock::Session`

## v1.0.0

First stable release!
