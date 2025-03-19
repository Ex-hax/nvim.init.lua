_G.authenticate = require('core.session.authenticate')

local Session = require('core.session.session')
_G.session = Session:__init__ {
    is_autoload = true
}

require('core.utils.auto_commands')
require('core.utils.user_commands')
