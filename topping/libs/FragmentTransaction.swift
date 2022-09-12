import Foundation

@objc(FragmentTransaction)
open class FragmentTransaction : NSObject {
    @objc static let OP_NULL = 0
    @objc static let OP_ADD = 1
    @objc static let OP_REPLACE = 2
    @objc static let OP_REMOVE = 3
    @objc static let OP_HIDE = 4
    @objc static let OP_SHOW = 5
    @objc static let OP_DETACH = 6
    @objc static let OP_ATTACH = 7
    @objc static let OP_SET_PRIMARY_NAV = 8
    @objc static let OP_UNSET_PRIMARY_NAV = 9
    @objc static let OP_SET_MAX_LIFECYCLE = 10
    
    @objc static let TRANSIT_ENTER_MASK = 0x1000
    @objc static let TRANSIT_EXIT_MASK = 0x2000
    
    @objc static let TRANSIT_UNSET = -1
    @objc static let TRANSIT_NONE = 0
    @objc static let TRANSIT_FRAGMENT_OPEN = 1 | TRANSIT_ENTER_MASK
    @objc static let TRANSIT_FRAGMENT_CLOSE = 2 | TRANSIT_EXIT_MASK
    @objc static let TRANSIT_FRAGMENT_FADE = 3 | TRANSIT_ENTER_MASK
    @objc static let TRANSIT_FRAGMENT_MATCH_ACTIVITY_OPEN = 4 | TRANSIT_ENTER_MASK
    @objc static let TRANSIT_FRAGMENT_MATCH_ACTIVITY_CLOSE = 4 | TRANSIT_EXIT_MASK
    
    @objc var mFragmentFactory: FragmentFactory?
    
    @objc var mOps: Array<Op> = Array()
    @objc var mEnterAnim: String = ""
    @objc var mExitAnim: String = ""
    @objc var mPopEnterAnim: String = ""
    @objc var mPopExitAnim: String = ""
    @objc var mTransition: Int = -1
    @objc var mAddToBackStack: Bool = false
    @objc var mAllowedAddToBackStack = true
    @objc var mName: String? = nil
    
    var mSharedElementSourceNames: Array<String>? = nil
    var mSharedElementTargetNames: Array<String>? = nil
    var mReorderingAllowed = false
    
    var mCommitRunnables: Array<Runnable>? = nil
    
    override init() {
        mFragmentFactory = nil
    }
    
    init(fragmentFactory: FragmentFactory, ft: FragmentTransaction) {
        mFragmentFactory = fragmentFactory
        mEnterAnim = ft.mEnterAnim
        mExitAnim = ft.mExitAnim
        mPopEnterAnim = ft.mPopEnterAnim
        mPopExitAnim = ft.mPopExitAnim
        mTransition = ft.mTransition
        mAddToBackStack = ft.mAddToBackStack
        mAllowedAddToBackStack = ft.mAllowedAddToBackStack
        mName = ft.mName
        super.init()
        ft.mOps.forEach {
            mOps.append($0)
        }
    }
    
    func addOp(op: Op)
    {
        mOps.append(op)
        op.mEnterAnim = mEnterAnim
        op.mExitAnim = mExitAnim
        op.mPopEnterAnim = mPopEnterAnim
        op.mPopExitAnim = mPopExitAnim
    }
    
    private func createFragment(type: LuaFragment.Type, args: Dictionary<String, Any>?) -> LuaFragment {
        //TODO
        return LuaFragment.create(LuaContext.init(), "")
    }
    
    @objc public func add(type: LuaFragment.Type, args: Dictionary<String, Any>?, tag: String?) -> FragmentTransaction {
        return add(fragment: createFragment(type: type, args: args), tag: tag)
    }
    
    @objc public func add(fragment: LuaFragment, tag: String?) -> FragmentTransaction {
        doAddOp(containerViewId: nil, fragment: fragment, tag: tag, opcmd: FragmentTransaction.OP_ADD)
        return self
    }
    
    @objc public func add(containerViewId: String?, type: LuaFragment.Type, args: Dictionary<String, Any>?) -> FragmentTransaction {
        return add(containerViewId: containerViewId, fragment: createFragment(type: type, args: args))
    }
    
    @objc public func add(containerViewId: String?, fragment: LuaFragment) -> FragmentTransaction {
        doAddOp(containerViewId: containerViewId, fragment: fragment, tag: nil, opcmd: FragmentTransaction.OP_ADD)
        return self
    }
    
    @objc public func add(containerViewId: String?, type: LuaFragment.Type, args: Dictionary<String, Any>?, tag: String?) -> FragmentTransaction {
        return add(containerViewId: containerViewId, fragment: createFragment(type: type, args: args), tag: tag)
    }
    
    @objc public func add(containerViewId: String?, fragment: LuaFragment, tag: String?) -> FragmentTransaction {
        doAddOp(containerViewId: containerViewId, fragment: fragment, tag: tag, opcmd: FragmentTransaction.OP_ADD)
        return self
    }
    
    @objc public func add(container: LGViewGroup, fragment: LuaFragment, tag: String?) -> FragmentTransaction {
        fragment.mContainer = container
        return add(containerViewId: container.getId(), fragment: fragment, tag: tag)
    }
    
    @objc public func doAddOp(containerViewId: String?, fragment: LuaFragment, tag: String?, opcmd: Int) {
        /*if(fragment.mPreviousWho != nil)
        {
            
        }*/
        if(tag != nil) {
            fragment.mTag = tag
        }
        if(containerViewId != nil) {
            fragment.mFragmentId = containerViewId
            fragment.mContainerId = fragment.mFragmentId
        }
        addOp(op: Op(cmd: opcmd, fragment: fragment))
    }
    
    @objc public func replace(containerViewId: String?, type: LuaFragment.Type, args: Dictionary<String, Any>?) -> FragmentTransaction {
        return replace(containerViewId: containerViewId, type: type, args: args, tag: nil)
    }
    
    @objc public func replace(containerViewId: String?, fragment: LuaFragment) -> FragmentTransaction {
        return replace(containerViewId: containerViewId, fragment: fragment, tag: nil)
    }
    
    @objc public func replace(containerViewId: String?, type: LuaFragment.Type, args: Dictionary<String, Any>?, tag: String?)  -> FragmentTransaction {
        return replace(containerViewId: containerViewId, fragment: createFragment(type: type, args: args), tag: tag)
    }
    
    @objc public func replace(containerViewId: String?, fragment: LuaFragment, tag: String?) -> FragmentTransaction {
        if(containerViewId == nil) {
            return self
        }
        doAddOp(containerViewId: containerViewId, fragment: fragment, tag: tag, opcmd: FragmentTransaction.OP_REPLACE)
        return self
    }
    
    @objc public func remove(fragment: LuaFragment) -> FragmentTransaction {
        addOp(op: Op(cmd: FragmentTransaction.OP_REMOVE, fragment: fragment))
        
        return self
    }
    
    @objc public func hide(fragment: LuaFragment) -> FragmentTransaction {
        addOp(op: Op(cmd: FragmentTransaction.OP_HIDE, fragment: fragment))
        
        return self
    }
    
    @objc public func show(fragment: LuaFragment) -> FragmentTransaction {
        addOp(op: Op(cmd: FragmentTransaction.OP_SHOW, fragment: fragment))
        
        return self
    }
    
    @objc public func detach(fragment: LuaFragment) -> FragmentTransaction {
        addOp(op: Op(cmd: FragmentTransaction.OP_DETACH, fragment: fragment))
        
        return self
    }
    
    @objc public func attach(fragment: LuaFragment) -> FragmentTransaction {
        addOp(op: Op(cmd: FragmentTransaction.OP_ATTACH, fragment: fragment))
        
        return self
    }
    
    @objc public func setPrimaryNavigationFragment(fragment: LuaFragment) -> FragmentTransaction {
        addOp(op: Op(cmd: FragmentTransaction.OP_SET_PRIMARY_NAV, fragment: fragment))
        
        return self
    }
    
    @objc public func setMaxLifecycle(fragment: LuaFragment, state: LifecycleState) -> FragmentTransaction {
        addOp(op: Op(cmd: FragmentTransaction.OP_SET_MAX_LIFECYCLE, fragment: fragment, state: state))
        
        return self
    }
    
    @objc public func isEmpty() -> Bool {
        return mOps.isEmpty
    }
    
    @objc public func setCustomAnimations(enter: String, exit: String) -> FragmentTransaction {
        return setCustomAnimations(enter: enter, exit: exit)
    }
    
    @objc public func setCustomAnimations(enter: String, exit: String, popEnter: String, popExit: String) -> FragmentTransaction {
        mEnterAnim = enter
        mExitAnim = exit
        mPopEnterAnim = popEnter
        mPopExitAnim = popExit
        
        return self
    }
    
    @objc public func addSharedElement(sharedElement: LGView, name: String) -> FragmentTransaction {
        var transitionName = sharedElement.transitionName
        if(transitionName == nil) {
            return self
        }
        if(mSharedElementSourceNames == nil) {
            mSharedElementSourceNames = Array()
            mSharedElementTargetNames = Array()
        } else if((mSharedElementTargetNames?.contains(name)) != nil) {
            return self
        } else if((mSharedElementSourceNames?.contains(name)) != nil) {
            return self
        }
        mSharedElementSourceNames?.append(transitionName!)
        mSharedElementTargetNames?.append(name)
        
        return self
    }
    
    @objc public func setTransition(transition: Int) -> FragmentTransaction {
        mTransition = transition
        return self
    }
    
    @objc public func addToBackStack(name: String) -> FragmentTransaction {
        if(!mAllowedAddToBackStack) {
            return self
        }
        
        mAddToBackStack = true
        mName = name
            
        return self
    }
    
    @objc public func isBackStackAllowed() -> Bool {
        return mAllowedAddToBackStack
    }
    
    @objc public func disallowAddToBackStack() -> FragmentTransaction {
        mAllowedAddToBackStack = false
        return self
    }
    
    @objc public func setReorderingAllowed(reorderingAllowed: Bool) -> FragmentTransaction {
        mReorderingAllowed = reorderingAllowed;
        return self;
    }
    
    func runOnCommit(runnable: Runnable) -> FragmentTransaction {
        disallowAddToBackStack()
        if(mCommitRunnables == nil) {
            mCommitRunnables = Array()
        }
        mCommitRunnables?.append(runnable)
        return self
    }
    
    @objc public func commit() -> Int {
        return 0
    }
    
    @objc public func commitAllowingStateLoss() -> Int {
        return 0
    }
}
