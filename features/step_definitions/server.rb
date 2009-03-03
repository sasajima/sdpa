Given /^I have created a server$/ do
  @qsub = StringIO.new( "" )
  @messenger = StringIO.new( "" )
  @server = OnlineSolver::Server.new( @messenger, :qsub => @qsub, :debug => true, :dry_run => true )
end


When /^I have started the server$/ do
  @server.start @solver, @ncpu, @input, @parameter
end


Then /^I should get qsub.sh containing line: (.*)$/ do | line |
  @qsub.string.split( "\n" ).should include( line )
end


Then /^I should observe debug print containing qsub command line: "(.*)"$/ do | exp |
  @messenger.string.split( "\n" ).inject( false ) do | result, each |
    Regexp.new( exp )=~ each
  end.should be_true
end
