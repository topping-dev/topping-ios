import UIKit

@objc(SavedState)
open class SavedState: NSObject {
    @objc public var mState: Dictionary<String, Any>
    
    @objc public init(state: Dictionary<String, Any>) {
        mState = state
    }
}

@objc(FragmentStateManager)
class FragmentStateManager: NSObject {
    var mDispatcher: FragmentLifecycleCallbacksDispatcher;
    var mFragmentStore: FragmentStore
    var mFragment: LuaFragment
    
    var mMovingToState = false;
    var mFragmentManagerState: Int = FragmentState.FS_INITIALIZING.rawValue
    
    init(dispatcher: FragmentLifecycleCallbacksDispatcher, fragmentStore: FragmentStore, fragment: LuaFragment) {
        mDispatcher = dispatcher
        mFragmentStore = fragmentStore
        mFragment = fragment
    }
    
    init(dispatcher: FragmentLifecycleCallbacksDispatcher, fragmentStore: FragmentStore, fragmentFactory: FragmentFactory, fs: FragmentStateStore) {
        mDispatcher = dispatcher
        mFragmentStore = fragmentStore
        mFragment = fs.instantiate(fragmentFactory: fragmentFactory)!
    }
    
    init(dispatcher: FragmentLifecycleCallbacksDispatcher, fragmentStore: FragmentStore, retainedFragment: LuaFragment, fs: FragmentStateStore ) {
        mDispatcher = dispatcher
        mFragmentStore = fragmentStore
        mFragment = retainedFragment
        mFragment.mSavedViewState = nil
        mFragment.mSavedViewRegistryState = nil
        mFragment.mBackStackNesting = 0
        mFragment.mInLayout = false
        mFragment.mAdded = false
        mFragment.mTargetWho = mFragment.mTarget != nil ? mFragment.mTargetWho : nil
        mFragment.mTarget = nil
        if(fs.mSavedFragmentState != nil) {
            mFragment.mSavedFragmentState = fs.mSavedFragmentState?.objcDictionary
        }
        else {
            mFragment.mSavedFragmentState = Dictionary<String, Any>().objcDictionary
        }
    }
    
    func getFragment() -> LuaFragment {
        return mFragment
    }
    
    func setFragmentManagerState(state: Int) {
        mFragmentManagerState = state
    }
    
    func computeExpectedState() -> Int {
        if(mFragment.mFragmentManager == nil)
        {
            return mFragment.mState
        }
        
        var maxState = mFragmentManagerState
        
        switch(mFragment.mMaxState) {
        case LifecycleState.LIFECYCLESTATE_RESUMED:
            break
        case LifecycleState.LIFECYCLESTATE_STARTED:
            maxState = min(maxState, FragmentState.FS_STARTED.rawValue)
            break
        case LifecycleState.LIFECYCLESTATE_CREATED:
            maxState = min(maxState, FragmentState.FS_CREATED.rawValue)
            break
        case LifecycleState.LIFECYCLESTATE_INITIALIZED:
            maxState = min(maxState, FragmentState.FS_ATTACHED.rawValue)
            break
        default:
            maxState = min(maxState, FragmentState.FS_INITIALIZING.rawValue)
        }
        
        if(mFragment.mFromLayout) {
            if(mFragment.mInLayout) {
                maxState = max(mFragmentManagerState, FragmentState.FS_VIEW_CREATED.rawValue)
                
                if(mFragment.lgview != nil && mFragment.lgview.parent == nil) {
                    maxState = min(maxState, FragmentState.FS_VIEW_CREATED.rawValue)
                }
            } else {
                if(mFragmentManagerState < FragmentState.FS_ACTIVITY_CREATED.rawValue) {
                    maxState = min(maxState, mFragment.mState)
                }
                else {
                    maxState = min(maxState, FragmentState.FS_CREATED.rawValue)
                }
            }
        }
        if(!mFragment.mAdded) {
            maxState = min(maxState, FragmentState.FS_CREATED.rawValue)
        }
        //effect TODO?
        if(mFragment.mRemoving) {
            if(mFragment.isInBackStack()) {
                maxState = min(maxState, FragmentState.FS_CREATED.rawValue)
            }
            else {
                maxState = min(maxState, FragmentState.FS_INITIALIZING.rawValue)
            }
        }
        
        if(mFragment.mDeferStart && mFragment.mState < FragmentState.FS_STARTED.rawValue) {
            maxState = min(maxState, FragmentState.FS_ACTIVITY_CREATED.rawValue)
        }
        
        return maxState
    }
    
    func moveToExpectedState() {
        if(mMovingToState) {
            return
        }
        mMovingToState = true
        
        var stateWasChanged = false
        var newState = computeExpectedState()
        
        while(newState != mFragment.mState) {
            stateWasChanged = true
            if(newState > mFragment.mState) {
                var nextStep = FragmentState(rawValue: (mFragment.mState + 1))!
                switch(nextStep) {
                case FragmentState.FS_ATTACHED:
                    attach()
                    break
                case FragmentState.FS_CREATED:
                    create()
                    break
                case FragmentState.FS_VIEW_CREATED:
                    ensureInflatedView()
                    createView()
                    break
                case FragmentState.FS_AWAITING_EXIT_EFFECTS:
                    activityCreated()
                    break
                case FragmentState.FS_ACTIVITY_CREATED:
                    if(mFragment.lgview != nil && mFragment.mContainer != nil) {
                        //TODO effects
                    }
                    mFragment.mState = FragmentState.FS_ACTIVITY_CREATED.rawValue
                    break
                case FragmentState.FS_STARTED:
                    start()
                    break
                case FragmentState.FS_AWAITING_ENTER_EFFECTS:
                    mFragment.mState = FragmentState.FS_AWAITING_ENTER_EFFECTS.rawValue
                    break
                case FragmentState.FS_RESUMED:
                    resume()
                    break
                default:
                    break
                }
            }
            else {
                var nextStep = FragmentState(rawValue: (mFragment.mState - 1))!
                switch(nextStep) {
                case FragmentState.FS_AWAITING_ENTER_EFFECTS:
                    pause()
                    break
                case FragmentState.FS_STARTED:
                    mFragment.mState = FragmentState.FS_STARTED.rawValue
                    break
                case FragmentState.FS_ACTIVITY_CREATED:
                    stop()
                    break
                case FragmentState.FS_AWAITING_EXIT_EFFECTS:
                    if(mFragment.mBeingSaved) {
                        saveState()
                    } else if(mFragment.lgview != nil) {
                        //TODO
                        /*if(mFragment.mSavedViewState == nil) {
                            saveViewState()
                        }*/
                    }
                    if(mFragment.lgview != nil && mFragment.mContainer != nil) {
                        //TODO effects
                    }
                    mFragment.mState = FragmentState.FS_AWAITING_EXIT_EFFECTS.rawValue
                    break
                case FragmentState.FS_VIEW_CREATED:
                    mFragment.mInLayout = false
                    mFragment.mState = FragmentState.FS_VIEW_CREATED.rawValue
                    break
                case FragmentState.FS_CREATED:
                    destroyFragmentView()
                    mFragment.mState = FragmentState.FS_CREATED.rawValue
                    break
                case FragmentState.FS_ATTACHED:
                    if(mFragment.mBeingSaved && mFragmentStore.getSavedState(who: mFragment.mWho) == nil) {
                        saveState()
                    }
                    destroy()
                    break
                case FragmentState.FS_INITIALIZING:
                    detach()
                    break
                default:
                    break
                }
            }
            newState = computeExpectedState()
        }
        if(!stateWasChanged && mFragment.mState == FragmentState.FS_INITIALIZING.rawValue) {
            if(mFragment.mRemoving && !mFragment.isInBackStack() && !mFragment.mBeingSaved) {
                mFragmentStore.getNonConfig().clearNonConfigState(f: mFragment)
                mFragmentStore.makeInactive(newlyActive: self)
                mFragment.initState()
            }
        }
        if(mFragment.mHiddenChanged) {
            if(mFragment.lgview != nil && mFragment.mContainer != nil) {
                //TODO effects?
            }
            if(mFragment.mFragmentManager != nil) {
                //TODO menu
                //mFragment.mFragmentManager.invalidateMenuForFragment(mFragment)
            }
            mFragment.mHiddenChanged = false
            mFragment.onHiddenChanged(mFragment.mHidden)
            mFragment.mChildFragmentManager.dispatchOnHiddenChanged()
        }
        mMovingToState = false
    }
    
    func ensureInflatedView() {
        if(mFragment.mFromLayout && mFragment.mInLayout && !mFragment.mPerformedCreateView) {
            mFragment.performCreateView(mFragment.performGetLayoutInflater(mFragment.mSavedFragmentState), nil, mFragment.mSavedFragmentState)
            if(mFragment.lgview != nil) {
                //TODO do i need it
                //mFragment.lgview.setSaveFromParentEnabled(false)
                mFragment.lgview.fragment = mFragment
                if(mFragment.mHidden) { mFragment.lgview.setVisibility(VISIBILITY.GONE.rawValue) }
                mFragment.performViewCreated()
                mDispatcher.dispatchOnFragmentViewCreated(f: mFragment, view: mFragment.lgview, savedInstanceState: mFragment.mSavedFragmentState?.swiftDictionary, onlyRecursive: false)
                mFragment.mState = FragmentState.FS_VIEW_CREATED.rawValue
            }
        }
    }
    
    func restoreState()
    {
        if(mFragment.mSavedFragmentState == nil) {
            return
        }
        //TODO mFragment.mSAvedViewState = mFragment.mSavedFragmentState.
    }
    
    func attach() {
        var targetFragmentStateManager: FragmentStateManager?
        if(mFragment.mTarget != nil) {
            targetFragmentStateManager = mFragmentStore.getFragmentStateManager(who: mFragment.mTarget.mWho)
            if(targetFragmentStateManager == nil) {
                return
            }
            mFragment.mTargetWho = mFragment.mTarget.mWho
            mFragment.mTarget = nil
        } else if(mFragment.mTargetWho != nil) {
            targetFragmentStateManager = mFragmentStore.getFragmentStateManager(who: mFragment.mTargetWho)
            if(targetFragmentStateManager == nil) {
                return
            }
        } else {
            targetFragmentStateManager = nil
        }
        if(targetFragmentStateManager != nil) {
            targetFragmentStateManager?.moveToExpectedState()
        }
        mFragment.mHost = mFragment.mFragmentManager.getHost()
        mFragment.mParent = mFragment.mFragmentManager.getParent()
        mDispatcher.dispatchOnFragmentPreAttached(f: mFragment, onlyRecursive: false)
        mFragment.performAttach()
        mDispatcher.dispatchOnFragmentAttached(f: mFragment, onlyRecursive: false)
    }
    
    func create() {
        if(!mFragment.mIsCreated) {
            mDispatcher.dispatchOnFragmentPreCreated(f: mFragment, savedInstanceState: mFragment.mSavedFragmentState?.swiftDictionary, onlyRecursive: false)
            mFragment.performCreate(mFragment.mSavedFragmentState)
            mDispatcher.dispatchOnFragmentCreated(f: mFragment, savedInstanceState: mFragment.mSavedFragmentState?.swiftDictionary, onlyRecursive: false)
        } else {
            mFragment.restoreChildFragmentState(mFragment.mSavedFragmentState)
            mFragment.mState = FragmentState.FS_CREATED.rawValue
        }
    }
    
    func createView() {
        if(mFragment.mFromLayout)
        {
            return
        }
        var layoutInflater = mFragment.performGetLayoutInflater(mFragment.mSavedFragmentState)
        var container: LGViewGroup? = nil
        if(mFragment.mContainer != nil) {
            container = mFragment.mContainer
        } else if(mFragment.mContainerId != nil) {
            var fragmentContainer = mFragment.mFragmentManager.getContainer()
            container = fragmentContainer?.onFindViewById(idVal: mFragment.mContainerId) as! LGViewGroup?
            if(container == nil) {
                if(!mFragment.mRestored) {
                    return
                }
            }
        }
        mFragment.mContainer = container
        mFragment.performCreateView(layoutInflater, container, mFragment.mSavedFragmentState)
        if(mFragment.lgview != nil) {
            //TODO
//            mFragment.lgview.setSaveFromParentEnabled(false)
            mFragment.lgview.fragment = mFragment
            if(container != nil) {
                addViewToContainer()
            }
            if(mFragment.mHidden) {
                mFragment.lgview.setVisibility(VISIBILITY.GONE.rawValue)
            }
            //TODO attach work
            mFragment.performViewCreated()
            mDispatcher.dispatchOnFragmentViewCreated(f: mFragment, view: mFragment.lgview, savedInstanceState: mFragment.mSavedFragmentState?.swiftDictionary, onlyRecursive: false)
            var postOnViewCreatedVisibility = mFragment.lgview.getVisibility()
            var postOnViewCreatedAlpha = mFragment.lgview.getAlpha()
            /*mFragment.setPostOnViewCreatedAlpha(postOnViewCreatedAlpha)
                        if(mFragment.mContainer != nil && postOnViewCreatedVisibility == VISIBILITY.VISIBLE.rawValue) {
                var focusedView = mFragment.lgview //findFocus
                if(fo)
            TODO
            }*/
        }
        mFragment.mState = FragmentState.FS_VIEW_CREATED.rawValue
    }
    
    func activityCreated() {
        mFragment.performActivityCreated(mFragment.mSavedFragmentState)
//        dispatch TODO
    }
    
    func start() {
        mFragment.performStart()
        mDispatcher.dispatchOnFragmentStarted(f: mFragment, onlyRecursive: false)
    }
    
    func resume() {
        //TODO focus
        mFragment.performResume()
        mDispatcher.dispatchOnFragmentResumed(f: mFragment, onlyRecursive: false)
        mFragment.mSavedFragmentState = nil
        mFragment.mSavedViewState = nil
        mFragment.mSavedViewRegistryState = nil
    }
    
    func pause() {
        mFragment.performPause()
        mDispatcher.dispatchOnFragmentPaused(f: mFragment, onlyRecursive: false)
    }
    
    func stop() {
        mFragment.performStop()
        mDispatcher.dispatchOnFragmentStopped(f: mFragment, onlyRecursive: false)
    }
    
    func saveState() {
        var fs = FragmentStateStore(frag: mFragment)
        
        if(mFragment.mState > FragmentState.FS_INITIALIZING.rawValue && fs.mSavedFragmentState == nil) {
            fs.mSavedFragmentState = saveBasicState()
            
            if(mFragment.mTargetWho != nil) {
                if(fs.mSavedFragmentState == nil)
                {
                    fs.mSavedFragmentState = Dictionary<String, Any>()
                }
                fs.mSavedFragmentState?["TARGET_STATE_TAG"] = mFragment.mTargetWho
                if(mFragment.mTargetRequestCode != 0) {
                    fs.mSavedFragmentState?["TARGET_REQUEST_CODE_STATE_TAG"] = mFragment.mTargetRequestCode
                }
            }
        }
        else {
            fs.mSavedFragmentState = mFragment.mSavedFragmentState?.swiftDictionary
        }
        mFragmentStore.setSavedState(who: mFragment.mWho, fragmentState: fs)
    }
    
    func saveInstanceState() -> SavedState? {
        if(mFragment.mState > FragmentState.FS_INITIALIZING.rawValue) {
            let result = saveBasicState()
            return result != nil ? SavedState(state: result!) : nil
        }
        
        return nil
    }
    
    func saveBasicState() -> Dictionary<String, Any>? {
        var result: Dictionary<String, Any>? = Dictionary<String, Any>()
        
        mFragment.performSaveInsanceState(result?.objcDictionary)
        mDispatcher.dispatchOnFragmentSaveInstanceState(f: mFragment, outState: result!, onlyRecursive: false)
        if(result == nil || ((result?.isEmpty) != nil))
        {
            result = nil
        }
        
        /*if(mFragment.lgview != nil) {
            saveViewState()
        }
        if(mFragment.mSavedViewState != nil) {
            
        }*/
        //TODO
        return result
    }
    
    func destroyFragmentView() {
        //TODO:Remove views here
        if(mFragment.mContainer != nil && mFragment.lgview != nil) {
            mFragment.mContainer.removeSubview(mFragment.lgview)
        }
        mFragment.performDestroyView()
        mDispatcher.dispatchOnFragmentViewDestroyed(f: mFragment, onlyRecursive: false)
        mFragment.mContainer = nil
        mFragment.lgview = nil
        //mFragment.mViewLifecycleOwner = nil
        mFragment.mViewLifecycleOwnerLiveData?.setValue(nil)
        mFragment.mInLayout = false
    }
    
    func destroy() {
        var beingRemoved = mFragment.mRemoving && !mFragment.isInBackStack()
        if(beingRemoved && !mFragment.mBeingSaved) {
            mFragmentStore.setSavedState(who: mFragment.mWho, fragmentState: nil)
        }
        var shouldDestroy = beingRemoved || mFragmentStore.getNonConfig().shouldDestroy(fragment: mFragment)
        if(shouldDestroy) {
            var host = mFragment.mHost
            var shouldClear: Bool
            if(host is ViewModelStoreOwner) {
                shouldClear = mFragmentStore.getNonConfig().isCleared()
            } else if(host?.context.form is LuaForm) {
                var activity = host?.context.form
                shouldClear = ((activity?.isChangingConfigurations()) != nil)
            } else {
                shouldClear = true
            }
            if((beingRemoved && !mFragment.mBeingSaved) || shouldClear)
            {
                mFragmentStore.getNonConfig().clearNonConfigState(f: mFragment)
            }
            mFragment.performDestory()
            mDispatcher.dispatchOnFragmentDestroyed(f: mFragment, onlyRecursive: false)
            for fragmentStateManager in mFragmentStore.getActiveFragmentStateManagers() {
                if(fragmentStateManager != nil) {
                    let fragment = fragmentStateManager.getFragment()
                    if(mFragment.mWho == fragment.mTargetWho) {
                        fragment.mTarget = mFragment
                        fragment.mTargetWho = nil
                    }
                }
            }
            if(mFragment.mTargetWho != nil) {
                mFragment.mTarget = mFragmentStore.findActiveFragment(who: mFragment.mTargetWho)
            }
            mFragmentStore.makeInactive(newlyActive: self)
        } else {
            if(mFragment.mTargetWho != nil) {
                let target = mFragmentStore.findActiveFragment(who: mFragment.mTargetWho)
                if(target != nil && target!.mRetainInstance) {
                    mFragment.mTarget = target
                }
            }
            mFragment.mState = FragmentState.FS_ATTACHED.rawValue
        }
    }
    
    func detach() {
        mFragment.performDetach()
        mDispatcher.dispatchOnFragmentDetached(f: mFragment, onlyRecursive: false)
        mFragment.mState = FragmentState.FS_INITIALIZING.rawValue
        mFragment.mHost = nil
        mFragment.mParent = nil
        mFragment.mFragmentManager = nil
        let beingRemoved = mFragment.mRemoving && !mFragment.isInBackStack()
        if(beingRemoved || mFragmentStore.getNonConfig().shouldDestroy(fragment: mFragment)) {
            mFragment.initState()
        }
    }
    
    func addViewToContainer() {
        let index = mFragmentStore.findFragmentIndexInContainer(f: mFragment)
        mFragment.mContainer.addSubview(mFragment.lgview, index)
        mFragment.lgview.componentAddMethod(mFragment.mContainer.getView(), mFragment.lgview.getView())
        mFragment.context.form.lgview.resizeAndInvalidate()
    }
}
