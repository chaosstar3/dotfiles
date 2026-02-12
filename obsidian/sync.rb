require 'json'
require 'fileutils'

def get_obsidian_vaults
	path = File.expand_path("~/Library/Application Support/obsidian/obsidian.json")
	file = File.read(path)
	json = JSON.parse(file)
	json["vaults"].map {|_, v| v["path"] }
end

def get_sync_targets
	Dir.glob("**/*", base: __dir__)
		.select {|f| File.file?(File.join(__dir__, f)) and f != __FILE__ }
end

# TODO: local sync
# TODO: functionize

vaults = get_obsidian_vaults
targets = get_sync_targets

targets.each do |target|
	puts "[sync] #{target}"

	vaults.each do |vault|
		dst = File.join(vault, target)
		dir = File.dirname(dst)
		FileUtils.mkdir_p(dir) unless File.exist?(dir)

		if File.symlink?(dst)
			dst_link = File.readlink(dst)
			if dst_link == target
				puts "- [skip] #{dst}"
			else
				puts "- [fail] symlink: #{target}"
			end
		elsif File.exist?(dst)
			puts "- [fail] regular file: #{dst}"
		else # dst does not exist
			File.symlink(target, dst)
			puts "- [link] #{target} -> #{dst}"
		end
	end
end
