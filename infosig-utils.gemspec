# frozen_string_literal: true

lib = 'infosig-utils'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = Regexp.last_match(1)

Gem::Specification.new do |spec|
  spec.name    = lib
  spec.version = version

  spec.summary = 'InfoSig Utilities'

  spec.authors  = ['Borna Novak']
  spec.email    = 'dosadnizub@gmail.com'
  spec.homepage = 'https://github.com/info-sig/infosig-utils'
  spec.licenses = ['MIT']

  spec.required_ruby_version = '>= 1.9'

  spec.require_paths = %w[lib]
  spec.files = `git ls-files -z lib`.split("\0")
  spec.files += %w[LICENSE.md README.md]
end
