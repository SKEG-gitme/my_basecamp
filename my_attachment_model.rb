require 'sqlite3'

class Attachment
  attr_accessor :id, :project_id, :filename, :format

  def initialize(attributes = {})
    @id = attributes['id']
    @project_id = attributes['project_id']
    @filename = attributes['filename']
    @format = attributes['format']
  end

  def self.connect
    db = SQLite3::Database.new 'my_basecamp.db'
    db.results_as_hash = true
    # Notice the Foreign Key linking to projects
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER,
        filename TEXT,
        format TEXT,
        FOREIGN KEY(project_id) REFERENCES projects(id)
      );
    SQL
    db
  end

  def self.create(params)
    db = self.connect
    db.execute(
      "INSERT INTO attachments (project_id, filename, format) VALUES (?, ?, ?)",
      [params[:project_id], params[:filename], params[:format]]
    )
    self.find(db.last_insert_row_id)
  end

  def self.find(id)
    db = self.connect
    row = db.execute("SELECT * FROM attachments WHERE id = ?", [id]).first
    row ? Attachment.new(row) : nil
  end

  def self.find_by_project(project_id)
    db = self.connect
    rows = db.execute("SELECT * FROM attachments WHERE project_id = ?", [project_id])
    rows.map { |row| Attachment.new(row) }
  end
end