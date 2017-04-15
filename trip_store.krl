ruleset trip_store {
  meta {
    name "trip_store"
    description << A ruleset to store trips >>
    author "Chris Ward"
    provides trips, long_trips, short_trips
    shares __testing, trips, long_trips, short_trips
  }

  global{
    __testing = { "queries": [ { "name": "hello", "args": [ "obj" ] },
                               { "name": "__testing" } ],
                  "events": [ { "domain": "car", "type" : "trip_reset"}, 
                              { "domain": "explicit", "type" : "trip_processed",
                                "attrs": [ "mileage", "timestamp" ] },
                              { "domain": "explicit", "type" : "found_long_trip",
                                "attrs": [ "mileage", "timestamp" ] } ]
    }
    trips = function() {
      out = ent:col_trips
    }
    long_trips = function() {
      out = ent:long_trips
    }
    short_trips = function() {
      out = trips().difference(long_trips())
    }
    clear_trip = { "_0": { "mileage": "0", "timestamp": "0" } } 
  }

  rule collect_trips {
    select when explicit trip_processed
    pre{
      mileage = event:attr("mileage")
      timestamp = event:attr("timestamp")
      index = ent:col_trips_index
    }
    always{
      ent:col_trips := ent:col_trips.defaultsTo(clear_trip, "Initialization needed");
      ent:col_trips{[index,"mileage"]} := mileage;
      ent:col_trips{[index,"timestamp"]} := timestamp;
      ent:col_trips_index := index+1
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre{
      mileage = event:attr("mileage")
      timestamp = event:attr("timestamp")
      index = ent:long_trips_index
    }
    always{
      ent:long_trips := ent:long_trips.defaultsTo(clear_trip, "Initialization needed");
      ent:long_trips{[index,"mileage"]} := mileage;
      ent:long_trips{[index,"timestamp"]} := timestamp;
      ent:long_trips_index := index+1
    }
  }

  rule clear_trips {
    select when car trip_reset
    always {
      ent:col_trips := clear_trip;
      ent:col_trips_index := 0;
      ent:long_trips := clear_trip;
      ent:long_trips_index := 0
    }
  }
}