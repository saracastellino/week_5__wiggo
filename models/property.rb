require_relative('../db/sql_runner')

class Property

  attr_reader :id
  attr_accessor :name, :category, :address, :place, :booking_platform_id, :sleeps, :daily_fee, :contacts

  def initialize( properties )
    @id = properties['id'].to_i if properties['id']
    @name = properties['name']
    @category = properties['category']
    @address = properties['address']
    @place = properties['place']
    @booking_platform_id = properties['booking_platform_id'].to_i
    @sleeps = properties['sleeps'].to_i
    @daily_fee = properties['daily_fee'].to_i
    @contacts = properties['contacts']
  end

  def save
    sql = "INSERT INTO properties (name, category, address, place, booking_platform_id, sleeps, daily_fee, contacts) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id"
    values = [@name, @category, @address, @place, @booking_platform_id, @sleeps, @daily_fee, @contacts]
    properties_data = SqlRunner.run(sql, values)
    @id = properties_data.first['id'].to_i
  end

  def self.delete_all
    sql = "DELETE FROM properties;"
    SqlRunner.run(sql)
  end

  def update
    sql = "UPDATE properties SET (name, category, address, place, booking_platform_id, sleeps, daily_fee, contacts) = ($1, $2, $3, $4, $5, $6, $7, $8)
    WHERE id = $9"
    values = [@name, @category, @address, @place, @booking_platform_id, @sleeps, @daily_fee, @contacts, @id]
    SqlRunner.run(sql, values)
  end

  def delete
    sql = "DELETE FROM properties WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def self.all
    sql = "SELECT * FROM properties"
    property_data = SqlRunner.run(sql)
    properties = map_items(property_data)
    return properties
  end

  def self.map_items(property_data)
    return property_data.map { |property| Property.new(property) }
  end

  def self.find(id)
    sql = "SELECT * FROM properties
    WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values).first
    property = Property.new(result)
    return property
  end

  def self.sort_by_place
    sql = "SELECT * FROM properties ORDER BY place ASC"
    property_data = SqlRunner.run(sql)
    properties = map_items(property_data)
    return properties
  end

  def self.sort_by_category
    sql = "SELECT * FROM properties ORDER BY category ASC"
    property_data = SqlRunner.run(sql)
    properties = map_items(property_data)
    return properties
  end

  def self.sort_by_name
    sql = "SELECT * FROM properties ORDER BY name ASC"
    property_data = SqlRunner.run(sql)
    properties = map_items(property_data)
    return properties
  end

# ------------------CREATE A GUESTS METHOD TO SEE PROPERTIES' GUESTS

  def guests
     sql = "SELECT guests.*
     FROM guests
     INNER JOIN bookings
     ON bookings.guest_id = guests.id
     WHERE property_id = $1"
     values = [@id]
     guests = SqlRunner.run(sql, values)
     guests_data = Guest.map_items(guests)
     return guests_data
   end

 # ------------------CREATE A BOOKINGS METHOD TO SEE PROPERTIES' BOOKINGS

  def bookings
    sql = "SELECT * FROM bookings WHERE property_id = $1"
    values = [@id]
    bookings = SqlRunner.run(sql, values)
    return Booking.map_items(bookings)
  end

   # ------------------CREATE A BOOKING_PLATFORM METHOD TO SEE PROPERTIES' BOOKINGS

  def booking_platform_name
    sql = "SELECT name FROM booking_platforms WHERE id = $1"
    values = [@booking_platform_id]
    booking_platform = SqlRunner.run(sql, values).first
    return booking_platform.fetch("name")
  end

  # ------------------------CALCULATING TOTAL EARNING FROM A PROPERTY

   def bookings_total_earning
     bookings = property.bookings
     bookings_fees = bookings.map{|booking| booking.total_earning}
     bookings_total_earned = bookings_fees.sum
     return bookings_total_earning
  end


end
