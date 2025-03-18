# Services Call - Police receive Location via Dispatch
In this simple snippet you can configure that if a player calls the police-dispatch via services app, the cops will receive the current location via Dispatch from LB-Tablet.
Only sending dispatch when call was exepted and sender is sending caller-id.

Add the following code to any serverside code.
--> server.lua:

```LUA
AddEventHandler("lb-phone:callAnswered", function(call)
    if call.company == "police" and not call.hideCallerId then -- and not call.hideCallerId
        local scord = GetEntityCoords(GetPlayerPed(exports["lb-phone"]:GetSourceFromNumber(call.caller.number)))
   
         local dispatch = {
                priority = 'low',
                code = "10-26",
                title = "Anruf eines Bürgers",
                description = "Dies ist der Standort des aktuellen Anrufes.",
                time = 600,
                job = 'police',
                location = {
                    label = 'Notrufpostion',
                    coords = { x = scord.x, y = scord.y }
                },
         }
           
         local dispatchId = exports["lb-tablet"]:AddDispatch(dispatch)
     end
end)
```
