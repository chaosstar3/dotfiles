require 'yaml'
require 'optparse'
#require 'pry'

TERM_CLEAR_LINE = "\e[0K"
TERM_CURSOR_UP = "\e[A"

class String
	RED="\033[0;31m"
	GREEN="\033[0;32m"
	YELLOW="\033[1;33m"
	BLUE="\033[1;34m"
	NC="\033[0m"

	def red
		RED + self + NC
	end
	def green
		GREEN + self + NC
	end
	def yellow
		YELLOW + self + NC
	end
	def blue
		BLUE + self + NC
	end
end

def info msg
	puts "[Info] ".blue + msg
end

def exe cmd
	puts "[>]".yellow + " #{cmd}"
	puts `#{cmd}`
	$?.success?
end

def check_cmd(cmd)
	path = `which #{cmd}`
	return $?.success?, path
end

def with_dir dir
	pwd = Dir.pwd
	unless Dir.exists? dir
		info("mkdir #{dir}")
		Dir.mkdir dir
	end
	Dir.chdir(dir)
	info("chdir #{dir}")
	yield
	Dir.chdir(pwd)
	info("chdir #{pwd}")
end


# env check
uname = `uname`
pkgkey, pkgman = case uname
	when /Darwin/ then ["brew", "brew"]
	when /Linux/  then ["apt", "sudo apt"]
	#when /old_linux/  then ["apt", "sudo apt-get"]
	else abort("Unknown os: #{uname}")
	end

# Argument
opt = {all: false}
OptionParser.new do |o|
	o.banner = "Usage: #{__FILE__} [options]"
	o.on('-a', '--all', 'check all') {opt[:all] = true}
end.parse!

yaml_file = File.join(File.dirname(__FILE__), 'ext.yml')
@yaml = YAML.load(File.read(yaml_file))
exts = opt[:all] ? @yaml.keys : ARGV
exts = exts.map {|e| [e, nil]}

loop do
	# check to install
	exts.select! do |e|
		ext = e[0]
		install = e[1]
		info = @yaml[ext]

		if info.nil?
			puts "[?] ".yellow + ext
			false
		else
			cmd = info["cmd"]
			cmd = ext if cmd.nil?
			r, path = check_cmd(cmd)
			if r
				puts "[+] ".green + "#{ext}: #{path}"
			else
				if install.nil?
					e[1] = true # to be installed
				end
			end
			!r
		end
	end

	exit if exts.empty?

	# select to install
	puts "select to install".blue
	exts.each_with_index do |(ext, install), i|
		if install
			puts "#{i + 1}. " + "[v] ".yellow + ext
		else
			puts "#{i + 1}. " + "[-] ".red + ext
		end
	end

	print '? [y/n] or numbers to toggle: '.blue
	input = $stdin.gets.chomp

	case input
	when 'Y','y' then ;
	when 'N','n' then exit
	else
		input.split(' ').each do |n|
			n = n.to_i
			if n >= 1 and n <= exts.length
				exts[n - 1][1] = !exts[n - 1][1]
			end
		end

		# rewrite menu
		print "\r" + (TERM_CURSOR_UP + TERM_CLEAR_LINE) * (exts.length + 2)
		next
	end

	exit if exts.select {|(ext, install)| install}.empty?

	# INSTALL
	with_dir File.join(Dir.home, ".bin/install") do
		exts.each do |(ext, install)|
			next if !install
			puts "[I] install #{ext}".blue
			info = @yaml[ext]
			fml = info["formula"]
			inst = info["install"]
			inst = [inst] unless inst.is_a?(Array)
			inst.each do |i|
				# get formula
				formula = case i
					when "pkgman"
						if pkgman.nil?
							puts "no package manager found"
							next
						end

						pkgname = fml[pkgkey] unless fml.nil?
						pkgname = ext if pkgname.nil?
						"#{pkgman} install #{pkgname}"
					when nil
						info["formula"].first[1]
					else
						info["formula"][i]
					end

				# do formula
				if formula.nil?
					puts "formula not found".red
				else
					r = formula.split("\n").detect {|l| !exe l}
					break if r.nil?
					break
				end
			end
		end
	end # with_dir
end # loop
