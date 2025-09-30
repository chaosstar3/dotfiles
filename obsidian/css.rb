require 'json'
require 'fileutils'

def get_obsidian_paths
	path = File.expand_path("~/Library/Application Support/obsidian/obsidian.json")
	file = File.read(path)
	json = JSON.parse(file)
	json["vaults"].map {|_, v| v["path"] }
end

def get_snippets
	dir = File.join(__dir__, "css")
	snippets = Dir.glob("*.css", base: dir)
	{dir: dir, snippets: snippets}
end

vaults = get_obsidian_paths
snippets = get_snippets

vaults.each do |vault|
	vault_snippet_dir = File.join(vault, ".obsidian", "snippets")
	FileUtils.mkdir_p(vault_snippet_dir)

	snippets[:snippets].each do |css|
		src = File.join(snippets[:dir], css)
		dst = File.join(vault_snippet_dir, css)

		if File.symlink?(dst)
			current_target = File.readlink(dst)
			if current_target == src
				puts "- [skip] #{dst}"
			else
				puts "- [fail] symlink: #{src}"
			end
		elsif File.exist?(dst)
			puts "- [fail] regular file: #{dst}"
		else # dst does not exist
			File.symlink(src, dst)
			puts "- [link] #{src} -> #{dst}"
		end
	end
end
