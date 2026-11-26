-- Template for the startup-lock users. Copy it to user.lua (which is NOT
-- committed) and put your own username and password hash in it:
--
--   cp src/lua/core/session/user.example.lua src/lua/core/session/user.lua
--
--   username = sha256 of the password
--   To get the hash of a password, run inside Neovim:
--     :echo sha256("your-password")
--
-- Without user.lua the login is turned off (Neovim opens with a warning).
return {
    -- yourname = "paste-the-sha256-hash-here",
}
