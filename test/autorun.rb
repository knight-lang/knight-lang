require 'minitest/autorun'
require_relative 'spec'

Kn::Test::Spec.executable = $*.dup
$*.clear

