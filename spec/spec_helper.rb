# frozen_string_literal: true

require 'pathname'

SPEC_ROOT = root = Pathname(__FILE__).dirname

if ENV['COVERAGE'] == 'true'
  require 'codacy-coverage'
  Codacy::Reporter.start(partial: true)
end

require 'warning'

Warning.ignore(/__FILE__/)
Warning.ignore(/__LINE__/)
Warning.process { |w| raise w } if ENV['FAIL_ON_WARNINGS'].eql?('true')

require 'dry/core/deprecations'
Dry::Core::Deprecations.set_logger!(SPEC_ROOT.join('../log/deprecations.log'))

require 'rom/core'

Dir[root.join('support/*.rb').to_s].each do |f|
  require f unless f.include?('coverage')
end

Dir[root.join('shared/*.rb').to_s].each do |f|
  require f
end

module SpecProfiler
  def report(*)
    require 'hotch'

    Hotch() do
      super
    end
  end
end

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.after do
    Test.remove_constants
  end

  config.around do |example|
    ConstantLeakFinder.find(example)
  end

  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.warnings = true

  config.reporter.extend(SpecProfiler) if ENV['PROFILE'] == 'true'

  config.include(SchemaHelpers)
end
