ruleset track_trips_2 {
  meta {
    name "track_trips_2"
    description << Another ruleset for tracking trips >>
    author "Chris Ward"
    shares __testing
  }

  global {
    __testing = { "queries": [ { "name": "hello", "args": [ "obj" ] },
                               { "name": "__testing" } ],
                  "events": [ { "domain": "car", "type" : "new_trip", 
                                "attrs": [ "mileage" ] },
                              { "domain": "explicit", "type" : "trip_processed"},
                              { "domain": "explicit", "type" : "found_long_trip"} ]
    }
    long_trip = 50
  }

  rule process_trip {
    select when car new_trip
    pre{
      mileage = event:attr("mileage")
    }
    send_directive("trip") with
      trip_length = mileage
    always{
      raise explicit event "trip_processed"
        attributes {"attrs": event:attrs(), "mileage": mileage}
    }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre{
      mileage = event:attr("mileage")
    }
    if mileage.as("Number") > long_trip then
      send_directive("a_long_trip")
        with mileage=mileage
    fired {
      raise explicit event "found_long_trip"
        attributes {"attrs": event:attrs()}
    }
    
  }
}
