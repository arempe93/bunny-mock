#!/usr/bin/env gem build
# encoding: utf-8

require 'base64'
require File.expand_path("../lib/bunny_mock/version", __FILE__)

Gem::Specification.new do |s|
	s.name = 'bunny-mock'
	s.version = BunnyMock::VERSION.dup
	s.summary = 'Mocking for the popular Bunny client for RabbitMQ'
	s.description = 'Easy to use mocking for testing the Bunny client for RabbitMQ'
	s.license = 'MIT'
	s.required_ruby_version = Gem::Requirement.new '>= 2.0'

	s.authors = [ 'Andrew Rempe' ]
	s.email =  [ Base64.encode64('YW5kcmV3cmVtcGVAZ21haWwuY29t\n') ]

	# Dependencies
	s.add_dependency "amq-protocol", ">= 2.0.1"

	# Files.
	s.has_rdoc = true
	s.extra_rdoc_files = [ 'README.md' ]
	s.files = `git ls-files`.split '\n'
	s.test_files = `git ls-files -- spec/*`.split '\n'
	s.require_paths = [ 'lib' ]
end
