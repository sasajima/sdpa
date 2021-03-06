require 'cucumber/rake/task'
require 'rake'
require 'rake/clean'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'


def rcov_dat
  File.join File.dirname( __FILE__ ), 'coverage.dat'
end


def rcov_opts
  [ "--aggregate #{ rcov_dat }", "--exclude lib/popen3.rb,lib/pshell.rb" ]
end


task :default => [ :verify_rcov ]


Cucumber::Rake::Task.new do | t |
  rm_f rcov_dat
  t.rcov = true
  t.rcov_opts = rcov_opts
end


desc "Run specs with RCov" 
Spec::Rake::SpecTask.new do | t |
  t.spec_files = FileList[ 'spec/**/*_spec.rb' ]
  t.spec_opts = [ '--color', '--format', 'nested' ]
  t.rcov = true
  t.rcov_opts = rcov_opts
end


task :verify_rcov => [ "features", "spec" ]
RCov::VerifyTask.new do | t |
  t.threshold = 100
end


def egrep pattern
  Dir[ '**/*.rb' ].each do | each |
    count = 0
    open( each ) do | f |
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{ each }:#{ count }:#{ line }"
        end
      end
    end
  end
end
 

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /(FIXME|TODO|TBD)/
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
