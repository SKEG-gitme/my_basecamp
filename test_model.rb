require_relative 'my_user_model'
require_relative 'my_project_model'

# 1. Create a User
puts "Creating user..."
user = User.create(firstname: "Alice", lastname: "Smith", email: "alice@test.com", password: "123")
puts "User Created: #{user.firstname} (ID: #{user.id})"

# 2. Create a Project for that User
puts "Creating project..."
project = Project.create(name: "Secret Basecamp", description: "Top secret stuff", user_id: user.id)
puts "Project Created: #{project.name} owned by User ID: #{project.user_id}"

# 3. List all projects
puts "All Projects in DB:"
Project.all.each { |p| puts "- #{p.name}" }