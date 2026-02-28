require 'sqlite3'

class Project
  attr_accessor :id, :name, :description, :user_id

  def initialize(attributes = {})
    @id = attributes['id']
    @name = attributes['name']
    @description = attributes['description']
    @user_id = attributes['user_id'] # This connects the project to the owner (User)
  end

  def self.connect
    db = SQLite3::Database.new 'my_basecamp.db'
    db.results_as_hash = true
    
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        user_id INTEGER,
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL
    db
  end

  # Create a project and associate it with a user_id (The Admin)
  def self.create(params)
    db = self.connect
    db.execute(
      "INSERT INTO projects (name, description, user_id) VALUES (?, ?, ?)",
      [params[:name], params[:description], params[:user_id]]
    )
    row = db.execute("SELECT * FROM projects WHERE id = last_insert_rowid()").first
    Project.new(row)
  end

  def self.all
    db = self.connect
    rows = db.execute("SELECT * FROM projects")
    rows.map { |row| Project.new(row) }
  end

  def self.find(id)
    db = self.connect
    row = db.execute("SELECT * FROM projects WHERE id = ?", [id]).first
    row ? Project.new(row) : nil
  end

  def self.update(id, field, value)
    db = self.connect
    db.execute("UPDATE projects SET #{field} = ? WHERE id = ?", [value, id])
    self.find(id)
  end

  def self.destroy(id)
    db = self.connect
    db.execute("DELETE FROM projects WHERE id = ?", [id])
  end
end