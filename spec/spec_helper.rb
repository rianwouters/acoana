require 'factory_girl'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.filter_run :focus => true
  config.alias_example_to :fit, :focus => true
  config.run_all_when_everything_filtered = true
end
