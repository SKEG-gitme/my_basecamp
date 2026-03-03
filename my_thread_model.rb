require 'sqlite3'

class ThreadModel
  attr_accessor :id, :project_id, :title, :content

  def initialize(attributes = {})
    @id = attributes['id']
    @project_id = attributes['project_id']
    @title = attributes['title']
    @content = attributes['content']
  end

  def self.connect
    db = SQLite3::Database.new 'my_basecamp.db'
    db.results_as_hash = true
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS threads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER,
        title TEXT,
        content TEXT,
        FOREIGN KEY(project_id) REFERENCES projects(id)
      );
    SQL
    db
  end

  def self.create(params)
    db = self.connect
    db.execute("INSERT INTO threads (project_id, title, content) VALUES (?, ?, ?)", 
               [params[:project_id], params[:title], params[:content]])
    self.find(db.last_insert_row_id)
  end

  def self.find(id)
    db = self.connect
    row = db.execute("SELECT * FROM threads WHERE id = ?", [id]).first
    row ? ThreadModel.new(row) : nil
  end

  def self.find_by_project(project_id)
    db = self.connect
    rows = db.execute("SELECT * FROM threads WHERE project_id = ?", [project_id])
    rows.map { |row| ThreadModel.new(row) }
  end
end