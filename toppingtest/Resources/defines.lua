-- Root folder of scripts
ScriptsRoot = "scripts";

-- 1 External SD
-- 2 Internal
-- 3 Assets
PrimaryLoad = 3;

-- Force load of external or internal scripts
ForceLoad = 1;

-- Root folder of user interface files
UIRoot = "ui";

-- Startup XML 
-- Leaving this "", will create empty view for tab system
-- if you want to use tab system, overload the create event of the
-- MainForm(LuaForm) and add tab using LuaTabForm.
MainUI = "main.xml"

-- Startup Form
MainForm = "Main";

AppStyle = "AppTheme";

--initconnection = require"debugger"
--initconnection("192.168.1.28", "10000", "luaidekey")
