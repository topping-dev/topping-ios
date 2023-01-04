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
            local to = LuaForm.CreateWithUI(form:GetContext(), LR.id.formTestLL, LR.layout.form);
            luacontext:StartForm(to)
        elseif index == 1 then
            local to = LuaForm.CreateWithUI(form:GetContext(), LR.id.hsvTestLL, LR.layout.hsv);
            luacontext:StartForm(to)
        elseif index == 2 then
            local to = LuaForm.CreateWithUI(form:GetContext(), LR.id.svTestLL, LR.layout.sv);
            luacontext:StartForm(to)
        elseif index == 3 then
            --Map
        elseif index == 4 then
            LuaDialog.MessageBox(form:GetContext(), LR.string.teststring, LR.string.teststring);
        elseif index == 5 then
            local datePicker = LuaDialog.Create(form:GetContext(), LuaDialog.DIALOG_TYPE_DATEPICKER);
            datePicker:SetPositiveButton(LR.string.ok, LuaTranslator.Register(datePicker, "DatePicker_PositiveButton"));
            datePicker:SetNegativeButton(LR.string.cancel, LuaTranslator.Register(datePicker, "DatePicker_NegativeButton"));
            datePicker:SetTitle(LR.string.title);
            datePicker:SetMessage(LR.string.message);
            datePicker:SetDateManual(17, 7, 1985);
            datePicker:Show();
        elseif index == 6 then
            local timePicker = LuaDialog.Create(form:GetContext(), LuaDialog.DIALOG_TYPE_TIMEPICKER);
            timePicker:SetPositiveButton(LR.string.ok, LuaTranslator.Register(timePicker, "TimePicker_PositiveButton"));
            timePicker:SetNegativeButton(LR.string.cancel, LuaTranslator.Register(timePicker, "TimePicker_NegativeButton"));
            timePicker:SetTitle(LR.string.title);
            timePicker:SetMessage(LR.string.message);
            timePicker:SetTimeManual(17, 7);
            timePicker:Show();
        elseif index == 7 then
            LuaToast.Show(form:GetContext(), LR.string.toast_message, 2000);
        elseif index == 8 then
            local to = LuaForm.CreateWithUI(form:GetContext(), LR.id.frameTest, LR.layout.frame);
            luacontext:StartForm(to)
        elseif index == 9 then
            local to = LuaForm.CreateWithUI(form:GetContext(), LR.id.constraintTest, LR.layout.constraint);
            luacontext:StartForm(to)
        end
    end);
    pAdapter:SetOnCreateViewHolder(function(adapter, parent, type, context)
        local inflator = LuaViewInflator.Create(context);
        local viewToRet = inflator:Inflate(LR.layout.testbedadapter, pGUI);
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
    LuaNavigationUI.setupWithNavController(toolbar, navController)
end

function Pager_Constructor(pViewPager, luacontext)
    local pagerAdapter = LGFragmentStateAdapter.CreateFromForm(luacontext:GetForm())
    pagerAdapter:SetCreateFragment(function(adapter, position)
        local args = {}
        args["position"] = position
        return LuaFragment.CreateWithArgs(luacontext, LR.id.formTestLL, args)
    end)
    pagerAdapter:SetGetItemCount(function(adapter)
        return 4
    end)
    pViewPager:SetAdapter(pagerAdapter)
    local tabLayout = luacontext:GetForm():GetViewById(LR.id.tab)
    pViewPager:SetTabLayout(tabLayout, function(pager, pos)
        local tab = LuaTab.Create()
        tab:SetText(tostring(pos))
        return tab
    end)
end

function MenuFragment_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:Inflate(LR.layout.form, container)
end

function ReceiveFragment_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:Inflate(LR.layout.testbed, container)
end

function FormTest_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:Inflate(LR.layout.form, container)
end

LuaEvent.RegisterUIEvent(LR.id.ListViewTest, LuaEvent.UI_EVENT_VIEW_CREATE, ListViewTest_Constructor);
LuaEvent.RegisterUIEvent(LR.id.ToolbarTest, LuaEvent.UI_EVENT_VIEW_CREATE, Toolbar_Constructor);
LuaEvent.RegisterUIEvent(LR.id.Main, LuaEvent.UI_EVENT_CREATE, Main_Constructor);
--LuaEvent.RegisterUIEvent(LR.id.pager, LuaEvent.UI_EVENT_VIEW_CREATE, Pager_Constructor);
LuaEvent.RegisterUIEvent(LR.id.menuFragment, LuaEvent.UI_EVENT_FRAGMENT_CREATE_VIEW, MenuFragment_Create_View);
LuaEvent.RegisterUIEvent(LR.id.receiveFragment, LuaEvent.UI_EVENT_FRAGMENT_CREATE_VIEW, ReceiveFragment_Create_View);
