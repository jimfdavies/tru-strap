Given(/^The vagrant machine is running$/) do
  command="vagrant status 2>&1"
  $output=`#{command}`
  unless $output.include? "The VM is running"
    raise "Vagrant machine does not appear to be running."
  end
end

When(/^I run vagrant provision$/) do
  command="vagrant provision 2>&1"
  $output=`#{command}`
end

When(/^I run vagrant ssh \-c and this command: (.*)$/) do |ssh_command|
  command="vagrant ssh -c #{ssh_command} 2>&1"
  $output=`#{command}`
end

Then(/^I should see in the output: (.*)$/) do |expected_string|
  unless $output.include? expected_string
    raise "Expected string '#{expected_string}' not found in output:\n\n#{$output}"
  end
end

Then(/^I want to view the output of this scenario$/) do
  puts $output
end
