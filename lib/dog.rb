require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def get_first_row_from_db
    ##
  end

  def self.create_table
    self.drop_table
    query = <<-SQL
      CREATE TABLE dogs (
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(query)
  end

  def self.drop_table
    query = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(query)
  end

  def save
    query = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(query, self.name, self.breed)
    query = <<-SQL
      SELECT id FROM dogs
      ORDER BY id DESC
      LIMIT 1;
    SQL
    @id = DB[:conn].execute(query)[0][0]
    self
  end

  def self.create(dog_hash)
    dog = self.new(dog_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    query = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
    SQL
    dog_data = DB[:conn].execute(query, id)[0]
    self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    query = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
    SQL
    dog_data = DB[:conn].execute(query, name)[0]
    self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end

  def self.find_or_create_by(dog_hash)
    query = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    dog_data = DB[:conn].execute(query, dog_hash[:name], dog_hash[:breed])[0]
    if !!dog_data
      self.new_from_db(dog_data)
    else
      self.create(dog_hash)
    end
  end

  def update
    query = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(query, self.name, self.id)
  end
end
