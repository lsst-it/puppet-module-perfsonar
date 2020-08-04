# @summary Manage MaDDash
#
# @example
#   include maddash
#
class perfsonar::maddash {
  require 'perfsonar'
  require 'perfsonar::repo'

  package { $::perfsonar::maddash_package:
    ensure => 'installed',
  }
}
