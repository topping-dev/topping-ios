import UIKit

@objc(FragmentContainer)
public protocol FragmentContainer {
    @objc func onFindViewById(idVal: String?) -> LGView?
    @objc func onHasView() -> Bool
    @objc func instantiate(context: LuaContext, arguments: Dictionary<String, Any>?) -> LuaFragment
}

@objc(LuaFormHostCallback)
open class LuaFormHostCallbacks: FragmentHostCallback, ViewModelStoreOwner, OnBackPressedDispatcherOwner {
    @objc
    public init(form: LuaForm) {
        super.init(form: form, context: form.context)
    }
    
    public func getLifecycle() -> Lifecycle! {
        return form?.lifecycleRegistry
    }
    
    public func getViewModelStore() -> ViewModelStore! {
        return form?.getViewModelStore()
    }
    
    public func getOnBackPressedDispatcher() -> OnBackPressedDispatcher {
        return (form?.onBackPressedDispatcher!)!
    }
    
    public override func onGetLayoutInflater() -> LGLayoutParser? {
        return LGFragmentLayoutParser.getInstance()
    }
}

@objc(FragmentHostCallback)
open class FragmentHostCallback: NSObject, FragmentContainer {
    var form: LuaForm?
    var context: LuaContext
    @objc public var fragmentManager = FragmentManager()
    var runnableArray = Array<Runnable>()
    
    init(context: LuaContext) {
        self.context = context
        super.init()
        self.fragmentManager.setHost(host: self)
    }
    
    init(form: LuaForm?, context: LuaContext) {
        self.form = form
        self.context = context
        super.init()
        self.fragmentManager.setHost(host: self)
    }
    
    @objc
    public func onFindViewById(idVal: String?) -> LGView? {
        return form?.getViewById(idVal)
    }
    
    @objc
    public func onHasView() -> Bool {
        return true
    }
    
    @objc
    public func onShouldSaveFragmentState(fragment: LuaFragment) -> Bool
    {
        return true;
    }
    
    @objc
    public func onGetLayoutInflater() -> LGLayoutParser?
    {
        return LGParser.getInstance().pLayout
    }
    
    @objc
    public func onGetHost() -> Any?
    {
        return form?.fragmentManager.getHost()
    }
    
    @objc
    public func onSupportInvalidateOptionsMenu()
    {
        
    }
    

    /*    /**
         * Starts a new {@link Activity} from the given fragment.
         * See {@link FragmentActivity#startActivityForResult(Intent, int)}.
         */
        public void onStartActivityFromFragment(@NonNull Fragment fragment,
                @SuppressLint("UnknownNullness") Intent intent, int requestCode) {
            onStartActivityFromFragment(fragment, intent, requestCode, null);
        }

        /**
         * Starts a new {@link Activity} from the given fragment.
         * See {@link FragmentActivity#startActivityForResult(Intent, int, Bundle)}.
         */
        public void onStartActivityFromFragment(
                @NonNull Fragment fragment, @SuppressLint("UnknownNullness") Intent intent,
                int requestCode, @Nullable Bundle options) {
            if (requestCode != -1) {
                throw new IllegalStateException(
                        "Starting activity with a requestCode requires a FragmentActivity host");
            }
            ContextCompat.startActivity(mContext, intent, options);
        }

        /**
         * Starts a new {@link IntentSender} from the given fragment.
         * See {@link Activity#startIntentSender(IntentSender, Intent, int, int, int, Bundle)}.
         *
         * @deprecated Have your FragmentHostCallback implement {@link ActivityResultRegistryOwner}
         * to allow Fragments to use
         * {@link Fragment#registerForActivityResult(ActivityResultContract, ActivityResultCallback)}
         * with {@link StartIntentSenderForResult}. This method will still be called when Fragments
         * call the deprecated <code>startIntentSenderForResult()</code> method.
         */
        @Deprecated
        public void onStartIntentSenderFromFragment(@NonNull Fragment fragment,
                @SuppressLint("UnknownNullness") IntentSender intent, int requestCode,
                @Nullable Intent fillInIntent, int flagsMask, int flagsValues, int extraFlags,
                @Nullable Bundle options) throws IntentSender.SendIntentException {
            if (requestCode != -1) {
                throw new IllegalStateException(
                        "Starting intent sender with a requestCode requires a FragmentActivity host");
            }
            ActivityCompat.startIntentSenderForResult(mActivity, intent, requestCode, fillInIntent,
                    flagsMask, flagsValues, extraFlags, options);
        }

        /**
         * Requests permissions from the given fragment.
         * See {@link FragmentActivity#requestPermissions(String[], int)}
         *
         * @deprecated Have your FragmentHostCallback implement {@link ActivityResultRegistryOwner}
         * to allow Fragments to use
         * {@link Fragment#registerForActivityResult(ActivityResultContract, ActivityResultCallback)}
         * with {@link RequestMultiplePermissions}. This method will still be called when Fragments
         * call the deprecated <code>requestPermissions()</code> method.
         */
        @Deprecated
        public void onRequestPermissionsFromFragment(@NonNull Fragment fragment,
                @NonNull String[] permissions, int requestCode) {
        }

        /**
         * Checks whether to show permission rationale UI from a fragment.
         * See {@link FragmentActivity#shouldShowRequestPermissionRationale(String)}
         */
        public boolean onShouldShowRequestPermissionRationale(@NonNull String permission) {
            return false;
        }

        /**
         * Return {@code true} if there are window animations.
         */
        public boolean onHasWindowAnimations() {
            return true;
        }

        /**
         * Return the window animations.
         */
        public int onGetWindowAnimations() {
            return mWindowAnimations;
        }

        @Nullable
        @Override
        public View onFindViewById(int id) {
            return null;
        }

        @Override
        public boolean onHasView() {
            return true;
        }*/

    @objc
    public func getActivity() -> LuaForm?
    {
        return form
    }
    
    @objc
    public func getContext() -> LuaContext
    {
        return context
    }
    
    @objc
    public func instantiate(context: LuaContext, arguments: Dictionary<String, Any>?) -> LuaFragment {
        return LuaFragment.create(context, "", arguments?.objcDictionary)
    }
    
    @objc
    public func instantiate(context: LuaContext, className: String, arguments: Dictionary<String, Any>?) -> LuaFragment {
        let cls: LuaFragment.Type? = Utils.getClassForClassName(className: className)
        if(cls == nil)
        {
            NSLog("cannot instantiate fragment with class name %@, creating LuaFragment with luaid", className)
            return LuaFragment.create(context, className)
        }
        let val = cls!.init()
        val.setArguments(arguments?.objcDictionary)
        return val
    }
}
