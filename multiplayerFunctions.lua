require "pubnub"
require "math"


function generateId()
    local id = system.getInfo( "deviceID" );
    return id;
end

playerId = 1

multiplayer = pubnub.new({
    publish_key = "pub-c-a585bb6f-5131-4fed-b4b7-a158a38cff38", -- YOUR PUBLISH KEY
    subscribe_key = "sub-c-ef701846-f039-11e3-928e-02ee2ddab7fe", -- YOUR SUBSCRIBE KEY
    secret_key = nil, -- YOUR SECRET KEY
    ssl = nil, -- ENABLE SSL?
    origin = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
})

function sendMessage(text)
    multiplayer:publish({
    channel = "space-front",
    message = text,
    callback = function(info)
    -- WAS MESSAGE DELIVERED?
        if info[1] then
            print("MESSAGE DELIVERED SUCCESSFULLY!")
        else
            print("MESSAGE FAILED BECAUSE -> " .. info[2])
        end
        end
    })
end

packReceived = "nada"
multiplayer:subscribe({
    channel = "space-front",
    callback = function(message)
        -- MESSAGE RECEIVED!!!
        if(message["protocolo"] == "positionPlayerBullet") then
              if(message["playerId"] ~= playerId) then
                packReceived = message
              end  
        end
    end,
    errorback = function()
        print("Network Connection Lost");
    end
})
    

function endConection()
    multiplayer:unsubscribe({
        channel = "space-front"
    })
end
