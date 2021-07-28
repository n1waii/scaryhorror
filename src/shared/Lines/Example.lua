return {
    Story = { -- text that goes along with cutscenes and the story go here
        ["302916"] = {
            Text = "This is an example with single text",
            Audio = "rbxassetid://12345678"
        },

        ["578913"] = {
            Text = {
                "This is an example",
                "with multiple text"
            },
            Audio = {
                "rbxassetid://12345678", -- audio for first text
                "rbxassetid://12345678" -- audio for second text
            }
        },
    },

    Misc = { -- text that plays when player does something goes here. for example, going into some dark room.
        ["403921"] = {
            Text = "This room is pretty dark",
            Audio = "rbxassetid://12345678"
        },
    }
}