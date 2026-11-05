module January
  class Workspace
    CONFIG_PATH = "config.yml".freeze

    def initialize(store = Store.new)
      @store = store
    end

    def add_project(name)
      project = Project.new(name)
      raise Error, "Project '#{project.name}' already exists." if project_exists?(project.name)

      @store.write(project_path(project.name), project.to_h)
      use_project(project.name) if active_name.nil?
      project
    end

    def project_names
      @store.list("projects")
    end

    def find_project(name)
      normalized = Project.normalize(name)
      data = @store.read(project_path(normalized))
      raise Error, "Project '#{normalized}' not found." unless data

      Project.from_h(data)
    end

    def remove_project(name)
      project = find_project(name)
      @store.delete(project_path(project.name))
      write_config("active_project" => nil) if active_name == project.name
      project
    end

    def update_project(name)
      project = find_project(name)
      result = yield project
      @store.write(project_path(project.name), project.to_h)
      result
    end

    def use_project(name)
      project = find_project(name)
      write_config("active_project" => project.name)
      project
    end

    def active_name
      config["active_project"]
    end

    def active_board
      active_project.active_board
    end

    def update_board
      update_project(active_project.name) { |project| yield project.active_board }
    end

    def active_project
      name = active_name
      raise Error, "No active project. Run 'january project use NAME'." unless name

      find_project(name)
    end

    private

    def project_exists?(name)
      !@store.read(project_path(name)).nil?
    end

    def project_path(name)
      "projects/#{name}.yml"
    end

    def config
      @store.read(CONFIG_PATH) || {}
    end

    def write_config(values)
      @store.write(CONFIG_PATH, config.merge(values))
    end
  end
end
