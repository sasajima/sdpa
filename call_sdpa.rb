#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH.unshift File.dirname( __FILE__ )

require 'fileutils'
require 'popen3'
require 'pshell'


################################################################################
# Arguments
################################################################################

$input_file = ARGV[ 0 ]
$parameter_file = ARGV[ 1 ]
$out_file_name = ARGV[ 2 ]
$solver = ARGV[ 3 ]
$ncpu = ARGV[ 4 ]


################################################################################
# Misc
################################################################################

def sdpara
  File.expand_path File.join( File.dirname( __FILE__ ), 'sdpara.rb' )
end


def ssh_identity 
  ENV[ 'SSH_IDENTITY' ] ? "-i #{ ENV[ 'SSH_IDENTITY' ] }": ''
end


def file_staging_command torque
  [ $input_file, $parameter_file ].collect do | each |
    "scp #{ ssh_identity } #{ each } #{ torque }:#{ each }"
  end.join( '; ' )
end


def ssh_command torque
  "ssh #{ ssh_identity } #{ torque } /usr/bin/ruby #{ sdpara } #{ $input_file } #{ $parameter_file } #{ $solver } #{ $ncpu } #{ ENV[ 'DEBUG' ] ? '1' : '0' }"
end


def command
  case $solver
  when 'sdpa'
    ssh_command 'laqua.indsys.chuo-u.ac.jp'
  when 'sdpara'
    file_staging_command + '; ' + ssh_command( 'sdpa01.indsys.chuo-u.ac.jp' )
  when 'sdpa_gmp'
    file_staging_command + '; ' + ssh_command( 'opt-laqua.indsys.chuo-u.ac.jp' )
  else
    raise "We should not reach here!"
  end
end


def debug_print message
  if ENV[ 'DEBUG' ]
    $stderr.puts message
  end
end


################################################################################
# Main
################################################################################

Popen3::Shell.open do | shell |
  out = File.open( $out_file_name, 'w' )

  # SDPA の出力はバッファリングを避けるためすべて stderr で飛んでくる
  shell.on_stderr do | line |
    out.puts line
    out.flush
    debug_print line
  end

  debug_print command
  shell.exec command
end
