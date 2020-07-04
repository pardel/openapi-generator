require_relative 'openapi'

class Builder
  def initialize(spec_name)
    @spec_name = spec_name
    @config = {}
    @destination = nil
  end

  def spec_folder
    path = File.expand_path File.dirname($0)
    return File.join(path, @spec_name)
  end

  def load_config
    # check if the spec folder exists
    puts "❌ Spec folder not present: #{spec_folder}" and return unless File.directory?(spec_folder)
    # check if .config.yml exists
    config_file = File.join(spec_folder, ".config.yml")
    puts "❌ Config file not present: #{config_file}" and return unless File.file?(config_file)
    # load file
    @config = YAML.load(File.read(config_file))
  end

  def check_config
    self.load_config
    # checking destination folder
    puts "❌ Destination not specified." and exit unless @config || @config["destination"]
    @destination = File.join(File.expand_path File.dirname($0), @config["destination"])
  end

  def generate
    puts "\nBuilding: #{@spec_name}\n"
    self.check_config
    puts "   => #{@destination}"

    openapi = OpenAPI.new(spec_folder, @destination)
    File.write(@destination, YAML.dump(openapi.structure))

    puts "\nDone!"
  end

end