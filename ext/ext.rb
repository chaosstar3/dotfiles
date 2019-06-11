require 'yaml'
require 'optparse'
#require 'pry'

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
	puts "[>]".green + " #{cmd}"
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
		Dir.mkdir
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

yaml_file = File.join(File.dirname(__FILE__), 'ext.yml')
@yaml = YAML.load(File.read(yaml_file))

def check list
	list.select do |e|
		msg_head = ""
		r = true

		info = @yaml[e]
		if info.nil?
			puts "[?] ".yellow + e
		else
			cmd = info["cmd"]
			cmd = e if cmd.nil?
			r, path = check_cmd(cmd)
			if r
				puts "[+] ".green + "#{e}: #{path}"
			else
				puts "[-] ".red + e
			end
		end
		!r
	end
end

# Argument
opt = {all: false}
OptionParser.new do |o|
	o.banner = "Usage: #{__FILE__} [options]"
	o.on('-a', '--all', 'check all') {opt[:all] = true}
end.parse!

# Validate
puts "check installed".blue
exts = check(opt[:all] ? @yaml.keys : ARGV)

puts "Following will be installed".blue
puts exts.join(' ')

loop do
	print '? [y/n]: '.blue
	case $stdin.gets.chomp
	when 'Y','y' then ;
	when 'N','n' then exts = []
	#when 'e' then binding.pry #TODO
	else next
	end
	break
end

exit if exts.empty?

# INSTALL
with_dir File.join(Dir.home, ".bin/install") do
	exts.each do |e|
		puts "[I] install #{e}".blue
		info = @yaml[e]

		fml = info["formula"]

		inst = info["install"]
		inst = [inst] unless inst.is_a?(Array)
		inst.each do |i|
			formula = case i
				when "pkgman"
					if pkgman.nil?
						puts "no package manager found"
						next
					end

					pkgname = fml[pkgkey] unless fml.nil?
					pkgname = e if pkgname.nil?
					"#{pkgman} install #{pkgname}"
				when nil
					info["formula"].first[1]
				else
					info["formula"][i]
				end

			if formula.nil?
				puts "formula not found".red
			else
				r = formula.split("\n").detect {|l| !exe l}
				break if r.nil?
			end
		end
	end
end # with_dir
