function DatePicker_PositiveButton(pGui)
	
end

function DatePicker_NegativeButton(pGui)
	
end

function TimePicker_PositiveButton(pGui)
	
end

function TimePicker_NegativeButton(pGui)
	
end

function ListViewTest_AdapterView_ItemSelected(pGui, listView, detailView, position, data)
	local form = LuaForm.GetActiveForm();
	if position == 0 then
		LuaForm.CreateWithUI(form:GetContext(), "formTest", "form.xml");
	elseif position == 1 then
		LuaForm.CreateWithUI(form:GetContext(), "hsvTest", "hsv.xml");
	elseif position == 2 then
		LuaForm.CreateWithUI(form:GetContext(), "svTest", "sv.xml");
	elseif position == 3 then
		--Map
	elseif position == 4 then
		LuaDialog.MessageBox(form:GetContext(), "Title", "Message");
	elseif position == 5 then
    local datePicker = LuaDialog.Create(form:GetContext(), LuaDialog.DIALOG_TYPE_DATEPICKER);
		datePicker:SetPositiveButton("Ok", LuaTranslator.Register(datePicker, "DatePicker_PositiveButton"));
		datePicker:SetNegativeButton("Cancel", LuaTranslator.Register(datePicker, "DatePicker_NegativeButton"));
		datePicker:SetTitle("Title");
		datePicker:SetMessage("Message");
		datePicker:SetDateManual(17, 7, 1985);
		datePicker:Show();
	elseif position == 6 then
		local timePicker = LuaDialog.Create(form:GetContext(), LuaDialog.DIALOG_TYPE_TIMEPICKER);
		timePicker:SetPositiveButton("Ok", LuaTranslator.Register(timePicker, "TimePicker_PositiveButton"));
		timePicker:SetNegativeButton("Cancel", LuaTranslator.Register(timePicker, "TimePicker_NegativeButton"));
		timePicker:SetTitle("Title");
		timePicker:SetMessage("Message");
		timePicker:SetTimeManual(17, 7);
		timePicker:Show();
	else
		LuaToast.Show(form:GetContext(), "Toast test", 2000);
	end
end

function ListViewTest_Constructor(pGUI, luacontext)
	local pAdapter = LGRecyclerViewAdapter.Create(luacontext, "ListAdapterTest");
	pAdapter:SetOnItemSelected(function(adapter, parent, detail, index, object)
        local form = LuaForm.GetActiveForm();
        if index == 0 then
            LuaForm.CreateWithUI(form:GetContext(), "formTest", "form.xml");
        elseif index == 1 then
            LuaForm.CreateWithUI(form:GetContext(), "hsvTest", "hsv.xml");
        elseif index == 2 then
            LuaForm.CreateWithUI(form:GetContext(), "svTest", "sv.xml");
        elseif index == 3 then
            --Map
        elseif index == 4 then
            LuaDialog.MessageBox(form:GetContext(), "Title", "Message");
        elseif index == 5 then
            local datePicker = LuaDialog.Create(form:GetContext(), LuaDialog.DIALOG_TYPE_DATEPICKER);
            datePicker:SetPositiveButton("Ok", LuaTranslator.Register(datePicker, "DatePicker_PositiveButton"));
            datePicker:SetNegativeButton("Cancel", LuaTranslator.Register(datePicker, "DatePicker_NegativeButton"));
            datePicker:SetTitle("Title");
            datePicker:SetMessage("Message");
            datePicker:SetDateManual(17, 7, 1985);
            datePicker:Show();
        elseif index == 6 then
            local timePicker = LuaDialog.Create(form:GetContext(), LuaDialog.DIALOG_TYPE_TIMEPICKER);
            timePicker:SetPositiveButton("Ok", LuaTranslator.Register(timePicker, "TimePicker_PositiveButton"));
            timePicker:SetNegativeButton("Cancel", LuaTranslator.Register(timePicker, "TimePicker_NegativeButton"));
            timePicker:SetTitle("Title");
            timePicker:SetMessage("Message");
            timePicker:SetTimeManual(17, 7);
            timePicker:Show();
        elseif index == 7 then
            LuaToast.Show(form:GetContext(), "Toast test", 2000);
        elseif index == 8 then
            LuaForm.CreateWithUI(form:GetContext(), "frameTest", "frame.xml");
        elseif index == 9 then
            LuaForm.CreateWithUI(form:GetContext(), "constraintTest", "constraint.xml");
        end
    end);
    pAdapter:SetOnCreateViewHolder(function(adapter, parent, type, context)
        local inflator = LuaViewInflator.Create(context);
        local viewToRet = inflator:ParseFile("testbedadapter.xml", pGUI);
        return viewToRet;
    end);
    pAdapter:SetOnBindViewHolder(function(adapter, view, index, object)
        local tvTitle = view:GetViewById(LR.id.testBedTitle);
        tvTitle:SetText(object);
        tvTitle:SetTextColorRef(LR.color.colorAccent);
    end);
    pAdapter:SetGetItemViewType(function(adapter, type)
        return 1;
    end);
	pAdapter:AddValue("Form Ui");
	pAdapter:AddValue("Horizontal Scroll View");
	pAdapter:AddValue("Vertical Scroll View");
	pAdapter:AddValue("Map");
	pAdapter:AddValue("Message Box");
	pAdapter:AddValue("Date Picker Dialog");
	pAdapter:AddValue("Time Picker Dialog");
	pAdapter:AddValue("Toast");
    pAdapter:AddValue("FrameLayout");
    pAdapter:AddValue("ConstraintLayout");
	pGUI:SetAdapter(pAdapter);
    pAdapter:Notify();
end

function Toolbar_Constructor(pToolbar, luacontext)
    pToolbar:SetSubtitle("Test title");
end

function Main_Constructor(pForm, luacontext)
    local navController = pForm:GetFragmentManager():findFragmentById(LR.id.nav_host_fragment):getNavController()
    local toolbar = pForm:GetViewById(LR.id.ToolbarTest)
    LuaNavigationUI.setupWithNavController(toolbar, navController)
end

LuaForm.RegisterFormEvent("ListViewTest", LuaForm.FORM_EVENT_CREATE, ListViewTest_Constructor);
LuaForm.RegisterFormEvent("ToolbarTest", LuaForm.FORM_EVENT_CREATE, Toolbar_Constructor);
LuaForm.RegisterFormEvent("Main", LuaForm.FORM_EVENT_CREATE, Main_Constructor);

function MenuFragment_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:Inflate(LR.layout.form, container)
end

function ReceiveFragment_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:Inflate(LR.layout.testbed, container)
end

LuaFragment.RegisterFragmentEvent("ListViewTest", LuaFragment.FRAGMENT_EVENT_CREATE, ListViewTest_Constructor);
LuaFragment.RegisterFragmentEvent("menuFragment", LuaFragment.FRAGMENT_EVENT_CREATE_VIEW, MenuFragment_Create_View);
LuaFragment.RegisterFragmentEvent("receiveFragment", LuaFragment.FRAGMENT_EVENT_CREATE_VIEW, ReceiveFragment_Create_View);
