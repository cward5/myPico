ruleset track_trips2 {
  meta {
    name "track_trips2"
    description << A ruleset for an echo server >>
    author "Chris Ward"
    shares __testing
  }

  global {
    __testing = { "queries": [ { "name": "hello", "args": [ "obj" ] },
                               { "name": "__testing" } ],
                  "events": [ { "domain": "echo", "type": "hello" },
                              { "domain": "echo", "type" : "message", 
                                "attrs": [ "mileage" ] } ]
    }
  }

  rule process_trip {
    select when echo message
    pre{
      mileage = event:attr("mileage")
    }
    send_directive("trip") with
      trip_length = mileage
  }
}