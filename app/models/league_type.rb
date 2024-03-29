class LeagueType < ActiveRecord::Base
  has_many :leagues

  def get_starting_slots
    @slots = JSON.parse(self.starting_slots_json) unless @slots
    @slots
  end

  def populate_positions(data)
    slot_data = []
    get_starting_slots.each { |slot|
      slot_data.push({ slot: slot, slot_desc: slot.join(","), data: nil })
    }

    if data
      slots = get_starting_slots
      data.each { |d|
        found_index = nil

        p = d.position.abbr
        options = slots.find_all{ |s| s.index(p) }.sort{ |s1, s2| s1.length <=> s2.length }
        found_index = slots.index(options.first) if options.length > 0
        raise "Invalid starters" unless found_index

        item = slot_data.find { |s| s[:slot] == options.first and s[:data].nil? }
        item[:data] = d if item
        slots.delete_at(found_index)
      }
    end

    slot_data
  end

  def validate_starting_positions(positions)
    valid = true
    slots = get_starting_slots

    positions.each { |p|
      found_index = nil
      puts slots.inspect
      puts p

      # Find matching options and sort them by length to use the most specific options first (i.e. WR should use WR before WR/TE)
      options = slots.find_all{ |s| s.index(p) }.sort{ |s1, s2| s1.length <=> s2.length }

      found_index = slots.index(options.first) if options.length > 0
      unless found_index
        valid = false
        break
      end
      slots.delete_at(found_index)
    }

    puts
    puts slots.inspect
    #valid = false if slots.count > 0

    valid
  end

  def validate_roster_position_limits
    limits = JSON.parse(self.position_limits_json)

  end
end
