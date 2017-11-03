ANSIBLE_DIR = "#{ANSIBLE_PATH}../ansible"
ANSIBLE_HOSTSFILE = 'hosts'
ANSIBLE_INVENTORY = "#{ANSIBLE_DIR}/#{ANSIBLE_HOSTSFILE}"
ANSIBLE_USER = 'root'

def load_inventory_file(inventory_file)
  config = {}
  category = nil
  inv = File.read(inventory_file)
  inv.lines.each do |line|
    if line != "\n"
      if line.strip.start_with?('[')
        category = line[1..-3]
        config[category] = []
      else
        config[category] << line[0..-2] unless category.nil?
      end
    end
  end
  config
end

def save_inventory_file(inventory_file, config)
  txt = ''
  config.each_key {|category|
    txt += "\n[#{category}]\n"
    config[category].each {|srv| txt += "#{srv}\n"}
  }
  File.open(inventory_file, 'w') {|f| f.puts txt}
end

def inventory_add_host(inventory_file, host, groups)
  config = load_inventory_file inventory_file
  groups.split.each {|group|
    config[group] = [] if config[group].nil?
    a = config[group].select { |e| /^#{host} / =~ e }
    config[group] << "#{host} ansible_user=#{ANSIBLE_USER}" if a.length == 0
  }
  save_inventory_file(inventory_file, config)
end

def inventory_del_host(inventory_file, host)
  inv = File.read(inventory_file)
  txt = ''
  inv.lines.each {|line|
    txt += "\n" if line.start_with?('[')
    if line.strip.length > 0
      txt += "#{line}" unless line.split[0] == host
    end
  }
  File.open(inventory_file, 'w') {|f| f.puts txt}
end