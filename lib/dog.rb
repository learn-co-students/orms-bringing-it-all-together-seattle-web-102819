class Dog

    attr_accessor :name, :breed, :id

    # def initialize(name:, breed:, id: nil)
    #     @id = id
    #     @name = name
    #     @breed = breed
    # end

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
            SQL
            DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
           self.update
        else
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new_from_db(dog_data)
        else
            dog = self.create(hash)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        dog = self.new_from_db(DB[:conn].execute(sql, name)[0])

    end


end