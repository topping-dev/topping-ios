function FormTestLL_Constructor(pGUI, luacontext)
	local button = pGUI:GetViewById(LR.id.formTestButton);
	button:SetOnClickListener(LuaTranslator.Register(button, "TestButton_Click"));
    button:SetTextRef(LR.string.teststring);
	local checkbox = pGUI:GetViewById(LR.id.formTestCheckBox);
	checkbox:SetOnCheckedChangedListener(LuaTranslator.Register(checkbox, "TestCheckBox_CheckedChanged"));
	local combobox = pGUI:GetViewById(LR.id.formTestComboBox);
    combobox:AddItem("Item 1", 1);
    combobox:AddItem("Item 2", 2);
    combobox:AddItem("Item 3", 3);
    combobox:AddItem("Item 4", 4);
	combobox:SetOnComboChangedListener(LuaTranslator.Register(combobox, "TestComboBox_Changed"));
	local edittext = pGUI:GetViewById(LR.id.formTestEt);
    local pb = pGUI:GetViewById(LR.id.formTestProgressBar);
    pb:SetMax(100);
    pb:SetProgress(35);
end

function TestCheckBox_CheckedChanged(pGUI, context, isChecked)
	LuaToast.Show(context, "CheckBox value is " .. tostring(isChecked), 1000);
end

function TestButton_Click(pGUI, context)
	LuaToast.Show(context, "Test button clicked", 1000);
 print(pGUI)
    pGUI:findNavController():navigate(LR.id.action_menuFragment_to_receiveFragment)
end

function TestComboBox_Changed(pGUI, context, name, value)
	LuaToast.Show(context, "Combobox id " .. name, 1000);
end

LuaForm.RegisterFormEvent("formTestLL", LuaForm.FORM_EVENT_CREATE, FormTestLL_Constructor);
LuaFragment.RegisterFragmentEvent("formTestLL", LuaFragment.FRAGMENT_EVENT_CREATE, FormTestLL_Constructor);
