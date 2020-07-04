class OpenAPI
  def initialize(spec_folder, destination)
    @spec_folder = spec_folder
    @destination = destination
  end

  def structure
    index_file = File.join(@spec_folder, 'index.yml')

    openapi = YAML.load(File.read(index_file))
    openapi["paths"] = self.load_paths
    openapi["components"] = self.load_components

    return openapi
  end


  def load_components
    components = {}
    components_folder = File.join(@spec_folder, "components")
    puts "❌ Components Folder not present: #{components_folder}" and return unless File.directory?(components_folder)

    %w(schemas parameters responses requestBodies securitySchemes).each do |component_type|
      component_type_folder = File.join(components_folder, component_type)
      next unless File.directory?(component_type_folder)
      files = Dir.glob("*.yml", base: component_type_folder)
      # next unless files.count > 0
      components_for_type = {}
      files.each do |file|
        file_yaml = YAML.load(File.read(File.join(component_type_folder, file)))
        components_for_type = components_for_type.merge(file_yaml)
      end
      components[component_type] = components_for_type
    end
    return components
  end

  def load_paths 
    paths = {}
    paths_folder = File.join(@spec_folder, "paths")
    puts "❌ paths Folder not present: #{paths_folder}" and return unless File.directory?(paths_folder)

    Dir.glob("*_*", base: paths_folder).sort.each do |path_folder|
      puts "\\_ #{path_folder}"
      properties = YAML.load(File.read(File.join(paths_folder, path_folder, "_index.yml" )))
      next unless properties && properties["path"]
      paths[properties["path"]] = load_path(File.join(paths_folder, path_folder))
    end

    return paths
  end

  def load_path(path_folder)
    path_structure = {}
    Dir.glob("*.yml", base: path_folder).sort.each do |method_file|
      puts "    \\__ #{method_file}"
      next if method_file == "_index.yml"
      properties = YAML.load(File.read(File.join(path_folder, method_file )))
      path_structure = path_structure.merge(properties)
    end
    return path_structure
  end
end