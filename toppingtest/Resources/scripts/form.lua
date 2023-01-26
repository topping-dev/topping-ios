function FormTestLL_Constructor(pGUI, luacontext)
	local button = pGUI:getViewById(LR.id.formTestButton);
	button:setOnClickListener(LuaTranslator.register(button, "TestButton_Click"));
    button:setTextRef(LR.string.teststring);
	local checkbox = pGUI:getViewById(LR.id.formTestCheckBox);
	checkbox:setOnCheckedChangedListener(LuaTranslator.register(checkbox, "TestCheckBox_CheckedChanged"));
	local combobox = pGUI:getViewById(LR.id.formTestComboBox);
    combobox:addItem("Item 1", 1);
    combobox:addItem("Item 2", 2);
    combobox:addItem("Item 3", 3);
    combobox:addItem("Item 4", 4);
	combobox:setOnComboChangedListener(LuaTranslator.register(combobox, "TestComboBox_Changed"));
	local edittext = pGUI:getViewById(LR.id.formTestEt);
    local pb = pGUI:getViewById(LR.id.formTestProgressBar);
    pb:setMax(100);
    pb:setProgress(35);
end

function TestCheckBox_CheckedChanged(pGUI, context, isChecked)
	LuaToast.showInternal(context, "CheckBox value is " .. tostring(isChecked), 1000);
end

function TestButton_Click(pGUI, context)
	LuaToast.show(context, LR.string.test_button_clicked, 1000);
    pGUI:findNavController():navigate(LR.id.action_menuFragment_to_receiveFragment)
end

function TestComboBox_Changed(pGUI, context, name, value)
	LuaToast.showInternal(context, "Combobox id " .. name, 1000);
end

LuaEvent.registerUIEvent(LR.id.formTestLL, LuaEvent.UI_EVENT_VIEW_CREATE, FormTestLL_Constructor)
