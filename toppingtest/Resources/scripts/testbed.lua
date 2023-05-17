function DatePicker_PositiveButton(pGui)
	
end

function DatePicker_NegativeButton(pGui)
	
end

function TimePicker_PositiveButton(pGui)
	
end

function TimePicker_NegativeButton(pGui)
	
end

function ListViewTest_AdapterView_ItemSelected(pGui, listView, detailView, position, data)
	local form = LuaForm.getActiveForm();
	if position == 0 then
		LuaForm.createWithUI(form:getContext(), "formTest", "form.xml");
	elseif position == 1 then
		LuaForm.createWithUI(form:getContext(), "hsvTest", "hsv.xml");
	elseif position == 2 then
		LuaForm.createWithUI(form:getContext(), "svTest", "sv.xml");
	elseif position == 3 then
		--Map
	elseif position == 4 then
		LuaDialog.messageBox(form:getContext(), "Title", "Message");
	elseif position == 5 then
    local datePicker = LuaDialog.create(form:getContext(), LuaDialog.DIALOG_TYPE_DATEPICKER);
		datePicker:setPositiveButton("Ok", LuaTranslator.register(datePicker, "DatePicker_PositiveButton"));
		datePicker:setNegativeButton("Cancel", LuaTranslator.register(datePicker, "DatePicker_NegativeButton"));
		datePicker:setTitle("Title");
		datePicker:setMessage("Message");
		datePicker:setDateManual(17, 7, 1985);
		datePicker:show();
	elseif position == 6 then
		local timePicker = LuaDialog.create(form:getContext(), LuaDialog.DIALOG_TYPE_TIMEPICKER);
		timePicker:setPositiveButton("Ok", LuaTranslator.register(timePicker, "TimePicker_PositiveButton"));
		timePicker:setNegativeButton("Cancel", LuaTranslator.register(timePicker, "TimePicker_NegativeButton"));
		timePicker:setTitle("Title");
		timePicker:setMessage("Message");
		timePicker:setTimeManual(17, 7);
		timePicker:show();
	else
		LuaToast.show(form:getContext(), "Toast test", 2000);
	end
end

function ListViewTest_Constructor(pGUI, luacontext)
	local pAdapter = LGRecyclerViewAdapter.create(luacontext, "ListAdapterTest");
	pAdapter:setOnItemSelected(function(adapter, parent, detail, index, object)
        local form = LuaForm.getActiveForm();
        if index == 0 then
            local to = LuaForm.createWithUI(form:GetContext(), LR.id.formTestLL, LR.layout.form);
            luacontext:startForm(to)
        elseif index == 1 then
            local to = LuaForm.createWithUI(form:GetContext(), LR.id.hsvTestLL, LR.layout.hsv);
            luacontext:startForm(to)
        elseif index == 2 then
            local to = LuaForm.createWithUI(form:GetContext(), LR.id.svTestLL, LR.layout.sv);
            luacontext:startForm(to)
        elseif index == 3 then
            --Map
        elseif index == 4 then
            LuaDialog.messageBox(form:getContext(), LR.string.teststring, LR.string.teststring);
        elseif index == 5 then
            local datePicker = LuaDialog.create(form:getContext(), LuaDialog.DIALOG_TYPE_DATEPICKER);
            datePicker:setPositiveButton(LR.string.ok, LuaTranslator.register(datePicker, "DatePicker_PositiveButton"));
            datePicker:setNegativeButton(LR.string.cancel, LuaTranslator.register(datePicker, "DatePicker_NegativeButton"));
            datePicker:setTitle(LR.string.title);
            datePicker:setMessage(LR.string.message);
            datePicker:setDateManual(17, 7, 1985);
            datePicker:show();
        elseif index == 6 then
            local timePicker = LuaDialog.create(form:getContext(), LuaDialog.DIALOG_TYPE_TIMEPICKER);
            timePicker:setPositiveButton(LR.string.ok, LuaTranslator.register(timePicker, "TimePicker_PositiveButton"));
            timePicker:setNegativeButton(LR.string.cancel, LuaTranslator.register(timePicker, "TimePicker_NegativeButton"));
            timePicker:setTitle(LR.string.title);
            timePicker:setMessage(LR.string.message);
            timePicker:setTimeManual(17, 7);
            timePicker:show();
        elseif index == 7 then
            LuaToast.show(form:getContext(), LR.string.toast_message, 2000);
        elseif index == 8 then
            local to = LuaForm.createWithUI(form:getContext(), LR.id.frameTest, LR.layout.frame);
            luacontext:startForm(to)
        elseif index == 9 then
            local to = LuaForm.createWithUI(form:getContext(), LR.id.constraintTest, LR.layout.constraint);
            luacontext:startForm(to)
        end
    end);
    pAdapter:setOnCreateViewHolder(function(adapter, parent, type, context)
        local inflator = LuaViewInflator.create(context);
        local viewToRet = inflator:inflate(LR.layout.testbedadapter, pGUI);
        return viewToRet;
    end);
    pAdapter:setOnBindViewHolder(function(adapter, view, index, object)
        local tvTitle = view:getViewById(LR.id.testBedTitle);
        tvTitle:setText(object);
        tvTitle:setTextColorRef(LR.color.colorAccent);
    end);
    pAdapter:setGetItemViewType(function(adapter, type)
        return 1;
    end);
	pAdapter:addValue("Form Ui");
	pAdapter:addValue("Horizontal Scroll View");
	pAdapter:addValue("Vertical Scroll View");
	pAdapter:addValue("Map");
	pAdapter:addValue("Message Box");
	pAdapter:addValue("Date Picker Dialog");
	pAdapter:addValue("Time Picker Dialog");
	pAdapter:addValue("Toast");
    pAdapter:addValue("FrameLayout");
    pAdapter:addValue("ConstraintLayout");
	pGUI:setAdapter(pAdapter);
    pAdapter:notify();
end

function Toolbar_Constructor(pToolbar, luacontext)
    pToolbar:setSubtitle("Test title");
end

function Main_Constructor(pForm, luacontext)
    local navController = pForm:getFragmentManager():findFragmentById(LR.id.nav_host_fragment):getNavController()
    local toolbar = pForm:getViewById(LR.id.ToolbarTest)
    LuaNavigationUI.setupWithNavController(toolbar, navController)
    LuaNavigationUI.setupWithNavController(toolbar, navController)
end

function Pager_Constructor(pViewPager, luacontext)
    local pagerAdapter = LGFragmentStateAdapter.createFromForm(luacontext:GetForm())
    pagerAdapter:cetCreateFragment(function(adapter, position)
        local args = {}
        args["position"] = position
        return LuaFragment.createWithArgs(luacontext, LR.id.formTestLL, args)
    end)
    pagerAdapter:setGetItemCount(function(adapter)
        return 4
    end)
    pViewPager:setAdapter(pagerAdapter)
    local tabLayout = luacontext:getForm():getViewById(LR.id.tab)
    pViewPager:setTabLayout(tabLayout, function(pager, pos)
        local tab = LuaTab.create()
        tab:setText(tostring(pos))
        return tab
    end)
end

function MenuFragment_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:inflate(LR.layout.form, container)
end

function ReceiveFragment_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:inflate(LR.layout.frame, container)
end

function FormTest_Create_View(pFragment, luacontext, inflater, container, savedInstanceState)
    return inflater:inflate(LR.layout.form, container)
end

LuaEvent.registerUIEvent(LR.id.ListViewTest, LuaEvent.UI_EVENT_VIEW_CREATE, ListViewTest_Constructor);
LuaEvent.registerUIEvent(LR.id.ToolbarTest, LuaEvent.UI_EVENT_VIEW_CREATE, Toolbar_Constructor);
LuaEvent.registerUIEvent(LR.id.Main, LuaEvent.UI_EVENT_CREATE, Main_Constructor);
--LuaEvent.registerUIEvent(LR.id.pager, LuaEvent.UI_EVENT_VIEW_CREATE, Pager_Constructor);
LuaEvent.registerUIEvent(LR.id.menuFragment, LuaEvent.UI_EVENT_FRAGMENT_CREATE_VIEW, MenuFragment_Create_View);
LuaEvent.registerUIEvent(LR.id.receiveFragment, LuaEvent.UI_EVENT_FRAGMENT_CREATE_VIEW, ReceiveFragment_Create_View);

