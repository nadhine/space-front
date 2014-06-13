require "pubnub"

multiplayer = pubnub.new({
    publish_key = "pub-c-a585bb6f-5131-4fed-b4b7-a158a38cff38", -- YOUR PUBLISH KEY
    subscribe_key = "sub-c-ef701846-f039-11e3-928e-02ee2ddab7fe", -- YOUR SUBSCRIBE KEY
    secret_key = nil, -- YOUR SECRET KEY
    ssl = nil, -- ENABLE SSL?
    origin = "pubsub.pubnub.com" -- PUBNUB CLOUD ORIGIN
})

multiplayer:publish({
    channel = "space-front",
    message = { "1234", 2, 3, 4 },
    callback = function(info)
    -- WAS MESSAGE DELIVERED?
        if info[1] then
            print("MESSAGE DELIVERED SUCCESSFULLY!")
        else
            print("MESSAGE FAILED BECAUSE -> " .. info[2])
    end
end
})

multiplayer:subscribe({
    channel = "space-front",
    callback = function(message)
        -- MESSAGE RECEIVED!!!
        print(message)
    end,
    errorback = function()
        print("Network Connection Lost")
    end
})



