require 'popen3'
require 'pshell'


module OnlineSolver
  class Client
    def initialize messenger, options
      @messenger = messenger
      @debug = options[ :debug ]
      @dry_run = options[ :dry_run ]
    end


    def start solver, input, parameter, ncpu, ssh_id
      @messenger.puts "OnlineSolver Client Started"

      @solver = solver
      @input = input
      @parameter = parameter
      @ncpu = ncpu
      @ssh_id = ssh_id

      Popen3::Shell.open do | shell |
        if scp_command
          debug scp_command if scp_command
          shell.exec scp_command unless @dry_run
        end
        debug ssh_command
        shell.exec ssh_command unless @dry_run
      end
    end


    def server
      case @solver
      when :sdpa
        'laqua.indsys.chuo-u.ac.jp'
      when :sdpa_ec2
        'ec2-67-202-18-171.compute-1.amazonaws.com'
      when :sdpara
        'sdpa01.indsys.chuo-u.ac.jp'
      when :sdpa_gmp
        'opt-laqua.indsys.chuo-u.ac.jp'
      else
        raise "Invalid solver: #{ @solver }"
      end
    end


    #############################################################################
    private
    #############################################################################


    def debug message
      if @debug
        @messenger.puts message
      end
    end


    def ssh_command
      case @solver
      when :sdpa, :sdpara
        "ssh #{ ssh_i_option }#{ server } #{ server_command } #{ input_remote } #{ parameter_remote } #{ @solver } #{ @ncpu }"
      when :sdpa_ec2, :sdpa_gmp
        "ssh #{ ssh_i_option }#{ server } #{ server_command } #{ input_remote } #{ parameter_remote } #{ @solver }"
      end
    end


    def scp_command
      case @solver
      when :sdpa
        nil
      when :sdpa_ec2, :sdpara, :sdpa_gmp
        "scp #{ ssh_i_option }#{ @input } #{ @parameter } #{ server }:#{ temp_dir }"
      end
    end


    def input_remote
      File.join temp_dir, File.basename( @input )
    end


    def parameter_remote
      File.join temp_dir, File.basename( @parameter )
    end


    def online_home
      "/home/online"
    end


    def temp_dir
      File.join online_home, "tmp"
    end


    def server_command
      File.join online_home, "bin/server.rb"
    end


    def ssh_i_option
      "-i #{ @ssh_id } " if @ssh_id
    end
  end
end
