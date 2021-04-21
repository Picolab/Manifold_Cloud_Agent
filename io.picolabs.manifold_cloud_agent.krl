ruleset io.picolabs.manifold_cloud_agent {
  meta {
    use module io.picolabs.aca alias aca
    use module io.picolabs.subscription alias subscription
    use module io.picolabs.wrangler alias wrangler
    use module io.picolabs.aca.trust_ping alias aca_ping
    shares __testing, isStatic, getLabel, getConnections, canPing, getPingStatus
  }
  global {
    __testing = { "queries":
      [ { "name": "__testing" }
      , { "name": "pingStatus" }, { "name": "canPing" }
      //, { "name": "entry", "args": [ "key" ] }
      ] , "events":[]
    }

    app = { "name":"Manifold Aries Cloud Agent", "version":"0.0" };
    
    getManifoldEci = function() {
        eci = subscription:established().filter(function(x) {
          x{"Tx_role"} == "manifold_pico"
        });
        eci[0]{"Tx"}
      }
    
    currentPage = function() {
      ent:current_page
    }
    
    neededRulesets = function() {
      options = ["io.picolabs.aca.trust_ping", "io.picolabs.aca.basicmessage"]
      options.difference(wrangler:installedRulesets())
    }
    
    isStatic = function() {
      wrangler:installedRulesets() >< "io.picolabs.aca.connections" => false | true
    }
    
    canPing = function(their_vk) {
      ent:connection_specs{their_vk}{"canPing"}
    }
    
    canMessage = function() {
      ent:connection_specs{their_vk}{"canMessage"}
    }
    
    getLabel = function() {
      aca:label()
    }
    
    getConnections = function() {
      aca:connections()
    }
    
    getPingStatus = function() {
      status = aca_ping:last_trust_pings().klog("blah")
      status{"lastPingResponse"}.klog("blah").isnull() => "disconnected" | "connected"
    }
    
}

  rule discovery {
    select when manifold apps
    send_directive("app discovered...",
                          {
                            "app": app,
                            "rid": meta:rid,
                            "iconURL": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAbkAAAGECAYAAACrsF5bAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAaGVYSWZNTQAqAAAACAAEAQYAAwAAAAEAAgAAARIAAwAAAAEAAQAAASgAAwAAAAEAAgAAh2kABAAAAAEAAAA+AAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAG5oAMABAAAAAEAAAGEAAAAAEO7bZIAAALkaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA1LjQuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx0aWZmOlBob3RvbWV0cmljSW50ZXJwcmV0YXRpb24+MjwvdGlmZjpQaG90b21ldHJpY0ludGVycHJldGF0aW9uPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICAgICA8dGlmZjpDb21wcmVzc2lvbj4xPC90aWZmOkNvbXByZXNzaW9uPgogICAgICAgICA8dGlmZjpSZXNvbHV0aW9uVW5pdD4yPC90aWZmOlJlc29sdXRpb25Vbml0PgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+Mzg4PC9leGlmOlBpeGVsWURpbWVuc2lvbj4KICAgICAgICAgPGV4aWY6Q29sb3JTcGFjZT4xPC9leGlmOkNvbG9yU3BhY2U+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj40NDE8L2V4aWY6UGl4ZWxYRGltZW5z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",
                            "bindings" : {}
                          } );
  }

  rule initialize {
    select when wrangler ruleset_added where rids >< meta:rid
    always {
      raise wrangler event "install_rulesets_requested"
        attributes {
          "rids": ["io.picolabs.aca"]
        }
    }
  }
  
  rule remove_agent {
    select when manifold uninstallapp where rid >< meta:rid
    always {
      raise wrangler event "uninstall_rulesets_requested"
        attributes { "rids": ["io.picolabs.aca", "io.picolabs.aca.trust_ping","io.picolabs.aca.connections","io.picolabs.aca.basicmessage", "s"] }
    }
  }
  
// ********************************************************************************************
// ***                        Adding/Removing features Rulesets                             ***
// ********************************************************************************************
  
  rule accept_connections {
    select when sovrin accept_connections
    pre {
    }
    if isStatic() then noop()
    fired {
      raise wrangler event "install_rulesets_requested"
        attributes { "rids": ["s","io.picolabs.aca.connections"].append(neededRulesets()) }
    }
  }
  
  rule make_agent_static {
    select when sovrin make_static
    pre {
    }
    if isStatic() then noop()
    notfired {
      raise wrangler event "uninstall_rulesets_requested"
        attributes { "rids": ["io.picolabs.aca.connections"] }
    }
  }
  
  rule accept_trust_pings {
    select when sovrin accept_trust_pings
    pre {
      their_vk = event:attr("their_vk")
    }
    if canPing(their_vk) then noop()
    notfired {
      ent:connection_specs := ent:connection_specs.set([their_vk, "canPing"], true)
    }
  }
  
  rule remove_trust_pings {
    select when sovrin remove_trust_pings
    pre {
      their_vk = event:attr("their_vk")
    }
    if canPing(their_vk) then noop()
    fired {
      ent:connection_specs := ent:connection_specs.set([their_vk, "canPing"], false)
    }
  }
  
// ********************************************************************************************
// ***                                    Miscellaneus                                      ***
// ********************************************************************************************
  
  rule connection_image {
    select when sovrin image
    send_directive("the image", {
      "icon": image_map[event:attr("label")]
    })
  }

  
  rule set_current_page {
    select when sovrin set_page
    always {
      ent:current_page := {}.put(event:attr("page"), event:attr("their_vk"))
    }
  }
  
  
  rule notify_incoming_message {
    select when didcomm_basicmessage message
    pre {
      their_key = event:attr("sender_key")
      conn = aca:connections(their_key)
      thing = aca:label()
      id = meta:picoId;
      manifold_pico = getManifoldEci()
      state = {"agent": aca:connections(their_key){"their_did"}}.put("tab", "2");
    }
    if not (ent:current_page{"chat"} == their_key) then
      event:send({"eci":manifold_pico, "domain":"manifold", "type":"add_notification", "attrs":{"picoId": id, "thing":thing, "app":"Sovrin Aries Cloud Agent", "message":"You got a message from "+conn{"label"}, "ruleset":"io.picolabs.manifold_cloud_agent", "state": state}})
    always {
    }
  }
}
