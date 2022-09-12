
import UIKit

@objc(BackStackRecordState)
class BackStackRecordState : NSObject {
    var mOps: Array<AnyObject>
    var mFragmentWhos: Array<String>
    var mOldMaxLifecycleStates: Array<Int>
    var mCurrentMaxLifecycleStates: Array<Int>
    var mTransition: Int = 0
    var mName: String = ""
    var mIndex: Int = -1
    var mReorderingAllowed: Bool = false
    
    init(bse: BackStackRecord) {
        let numOps = bse.mOps.count
        mOps = Array<AnyObject>()
        mFragmentWhos = Array<String>()
        mOldMaxLifecycleStates = Array<Int>()
        mCurrentMaxLifecycleStates = Array<Int>()
        
        if(!bse.mAddToBackStack) {
            return
        }
        
        var pos = 0
        for opNum in 0..<numOps {
            let op = bse.mOps[opNum]
            mOps[pos] = op.mCmd as AnyObject
            pos += 1
            mOps[pos] = op.mFromExpandedOp ? 1 as AnyObject : 0 as AnyObject
            pos += 1
            mOps[pos] = op.mEnterAnim as AnyObject
            pos += 1
            mOps[pos] = op.mExitAnim as AnyObject
            pos += 1
            mOps[pos] = op.mPopEnterAnim as AnyObject
            pos += 1
            mOps[pos] = op.mPopExitAnim as AnyObject
        }
        
    }
    
    func instantiate(fm: FragmentManager) -> BackStackRecord {
        let bse = BackStackRecord(manager: fm)
        fillInBackStackRecord(bse: bse)
        bse.mIndex = mIndex
        for num in 0..<mFragmentWhos.count {
            let fWho = mFragmentWhos[num]
            if(fWho != nil) {
                bse.mOps[num].mFragment = fm.findActiveFragment(who: fWho)
            }
        }
        bse.bumpBackStackNesting(amt: 1)
        return bse
    }
    
    func instantiate(fm: FragmentManager, fragments: Dictionary<String, LuaFragment>) -> BackStackRecord {
        let bse = BackStackRecord(manager: fm)
        fillInBackStackRecord(bse: bse)
        bse.mIndex = mIndex
        for num in 0..<mFragmentWhos.count {
            let fWho = mFragmentWhos[num]
            if(fWho != nil) {
                let fragment = fragments[fWho]
                if(fragment != nil) {
                    bse.mOps[num].mFragment = fragment
                }
            }
        }
        return bse
    }
    
    func fillInBackStackRecord(bse: BackStackRecord) {
        var pos = 0
        var num = 0
        while(pos < mOps.count) {
            let op = Op()
            op.mCmd = mOps[pos] as! Int
            pos += 1
            op.mOldMaxState = LifecycleState.init(rawValue: mOldMaxLifecycleStates[num])
            op.mCurrentMaxState = LifecycleState.init(rawValue: mCurrentMaxLifecycleStates[num])
            op.mFromExpandedOp = mOps[pos] as! Int != 0
            pos += 1
            op.mEnterAnim = mOps[pos] as! String
            pos += 1
            op.mExitAnim = mOps[pos] as! String
            pos += 1
            op.mPopEnterAnim = mOps[pos] as! String
            pos += 1
            op.mPopExitAnim = mOps[pos] as! String
            pos += 1
            bse.mEnterAnim = op.mEnterAnim
            bse.mExitAnim = op.mExitAnim
            bse.mPopEnterAnim = op.mPopEnterAnim
            bse.mPopExitAnim = op.mPopExitAnim
            bse.addOp(op: op)
            num += 1
        }
        bse.mTransition = mTransition
        bse.mName = mName
        bse.mAddToBackStack = true
        bse.mReorderingAllowed = mReorderingAllowed
    }
}

@objc(BackStackRecord)
class BackStackRecord : FragmentTransaction, BackStackEntry, OpGenerator {
    
    private var mManager: FragmentManager

    var mCommitted: Bool = false
    var mIndex = -1
    var mBeingSaved = false
    
    init(manager: FragmentManager) {
        mManager = manager
        super.init()
    }
    
    init(bse: BackStackRecord) {
        mManager = bse.mManager
        mCommitted = bse.mCommitted
        mIndex = bse.mIndex
        mBeingSaved = bse.mBeingSaved
        super.init()
    }
    
    func getId() -> Int {
        return mIndex
    }
    
    override func doAddOp(containerViewId: String?, fragment: LuaFragment, tag: String?, opcmd: Int) {
        super.doAddOp(containerViewId: containerViewId, fragment: fragment, tag: tag, opcmd: opcmd)
        fragment.mFragmentManager = mManager
    }
    
    override func remove(fragment: LuaFragment) -> FragmentTransaction {
        if(fragment.mFragmentManager != nil && fragment.mFragmentManager != mManager)
        {
            return self
        }
        return super.remove(fragment: fragment)
    }
    
    override func hide(fragment: LuaFragment) -> FragmentTransaction {
        if(fragment.mFragmentManager != nil && fragment.mFragmentManager != mManager)
        {
            return self
        }
        return super.hide(fragment: fragment)
    }
    
    override func show(fragment: LuaFragment) -> FragmentTransaction {
        if(fragment.mFragmentManager != nil && fragment.mFragmentManager != mManager)
        {
            return self
        }
        return super.show(fragment: fragment)
    }
    
    override func detach(fragment: LuaFragment) -> FragmentTransaction {
        if(fragment.mFragmentManager != nil && fragment.mFragmentManager != mManager)
        {
            return self
        }
        return super.detach(fragment: fragment)
    }
    
    override func setPrimaryNavigationFragment(fragment: LuaFragment) -> FragmentTransaction {
        if(fragment.mFragmentManager != nil && fragment.mFragmentManager != mManager)
        {
            return self
        }
        return super.setPrimaryNavigationFragment(fragment: fragment)
    }
    
    override func setMaxLifecycle(fragment: LuaFragment, state: LifecycleState) -> FragmentTransaction {
        if(fragment.mFragmentManager != nil && fragment.mFragmentManager != mManager)
        {
            return self
        }
        if(state == LifecycleState.LIFECYCLESTATE_INITIALIZED && fragment.mState > FragmentState.FS_INITIALIZING.rawValue) {
            return self
        }
        if(state == LifecycleState.LIFECYCLESTATE_DESTROYED) {
            return self
        }
        return super.setMaxLifecycle(fragment: fragment, state: state)
    }
    
    func bumpBackStackNesting(amt: Int) {
        if(!mAddToBackStack) {
            return
        }
        let numOps = mOps.count
        for opNum in 0..<numOps {
            let op = mOps[opNum]
            if(op.mFragment != nil) {
                op.mFragment?.mBackStackNesting += amt
            }
        }
    }
    
    func runOnCommitRunnables() {
        if(mCommitRunnables != nil) {
            for i in 0..<mCommitRunnables!.count {
                mCommitRunnables![i].run()
            }
            mCommitRunnables = nil
        }
    }
    
    override func commit() -> Int {
        return commitInternal(allowStateLoss: false)
    }
    
    override func commitAllowingStateLoss() -> Int {
        return commitInternal(allowStateLoss: true)
    }
    
    func commitInternal(allowStateLoss: Bool) -> Int {
        if(mCommitted)
        {
            return -2
        }
        mCommitted = true
        if(mAddToBackStack)
        {
            mIndex = mManager.allocBackStackIndex().get()
        }
        else
        {
            mIndex = -1
        }
        mManager.enqueueAction(action: self, allowStateLoss: allowStateLoss)
        return mIndex
    }
    
    func generateOps(records: inout Array<BackStackRecord>, isRecordPop: inout Array<Bool>) -> Bool {
        records.append(self)
        isRecordPop.append(false)
        if(mAddToBackStack) {
            mManager.addBackStackState(state: self)
        }
        return true
    }
    
    func executeOps() {
        let numOps = mOps.count
        for opNum in 0..<numOps
        {
            let op = mOps[opNum]
            let f = op.mFragment
            if(f != nil) {
                f!.mBeingSaved = mBeingSaved
                f!.setPopDirection(false)
                f!.setNextTransition(mTransition)
        
                switch(op.mCmd)
                {
                case FragmentTransaction.OP_ADD:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.setExitAnimationOrder(f: f!, isPop: false)
                    mManager.addFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_REMOVE:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.removeFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_HIDE:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.hideFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_SHOW:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.setExitAnimationOrder(f: f!, isPop: false)
                    mManager.showFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_DETACH:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.detachFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_ATTACH:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.setExitAnimationOrder(f: f!, isPop: false)
                    mManager.attachFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_SET_PRIMARY_NAV:
                    mManager.setPrimaryNavigationFragment(f: f!)
                    break
                case FragmentTransaction.OP_UNSET_PRIMARY_NAV:
                    mManager.setPrimaryNavigationFragment(f: nil)
                    break
                case FragmentTransaction.OP_SET_MAX_LIFECYCLE:
                    mManager.setMaxLifecycle(f: f!, state: op.mCurrentMaxState!)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func executePopOps() {
        let numOps = mOps.count
        for opNum in (0..<numOps).reversed()
        {
            let op = mOps[opNum]
            let f = op.mFragment
            if(f != nil) {
                f!.mBeingSaved = mBeingSaved
                f!.setPopDirection(true)
                f!.setNextTransition(mTransition)
                switch(op.mCmd)
                {
                case FragmentTransaction.OP_ADD:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.setExitAnimationOrder(f: f!, isPop: true)
                    mManager.removeFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_REMOVE:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.addFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_HIDE:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.showFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_SHOW:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.setExitAnimationOrder(f: f!, isPop: true)
                    mManager.hideFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_DETACH:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.attachFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_ATTACH:
                    f!.setAnimations(op.mEnterAnim, op.mExitAnim, op.mPopEnterAnim, op.mPopExitAnim)
                    mManager.setExitAnimationOrder(f: f!, isPop: true)
                    mManager.detachFragment(fragment: f!)
                    break
                case FragmentTransaction.OP_SET_PRIMARY_NAV:
                    mManager.setPrimaryNavigationFragment(f: nil)
                    break
                case FragmentTransaction.OP_UNSET_PRIMARY_NAV:
                    mManager.setPrimaryNavigationFragment(f: f)
                    break
                case FragmentTransaction.OP_SET_MAX_LIFECYCLE:
                    mManager.setMaxLifecycle(f: f!, state: op.mOldMaxState!)
                    break
                default:
                    break
                }
                
            }
        }
    }
    
    func expandOps(added: inout Array<LuaFragment?>, oldPrimaryNav: inout LuaFragment?) -> LuaFragment? {
        for var opNum in 0..<mOps.count
        {
            let op = mOps[opNum]
            switch (op.mCmd) {
            case FragmentTransaction.OP_ADD:
                added.append(op.mFragment)
                break;
            case FragmentTransaction.OP_ATTACH:
                added.append(op.mFragment)
                break;
            case FragmentTransaction.OP_REMOVE:
                added.remove(object: op.mFragment)
                if (op.mFragment == oldPrimaryNav) {
                    mOps.insert(Op(cmd: FragmentTransaction.OP_UNSET_PRIMARY_NAV, fragment: op.mFragment), at: opNum)
                    opNum+=1
                    oldPrimaryNav = nil
                }
            case FragmentTransaction.OP_DETACH:
                added.remove(object: op.mFragment)
                if (op.mFragment == oldPrimaryNav) {
                    mOps.insert(Op(cmd: FragmentTransaction.OP_UNSET_PRIMARY_NAV, fragment: op.mFragment), at: opNum)
                    opNum+=1
                    oldPrimaryNav = nil
                }
                break;
            case FragmentTransaction.OP_REPLACE:
                let f = op.mFragment
                let containerId = f?.mContainerId
                var alreadyAdded = false
                for i in (0..<added.count).reversed() {
                    let old = added[i]
                        if (old?.mContainerId == containerId) {
                            if (old == f) {
                                alreadyAdded = true
                            } else {
                                // This is duplicated from above since we only make
                                // a single pass for expanding ops. Unset any outgoing primary nav.
                                if (old == oldPrimaryNav) {
                                    mOps.insert(Op(cmd:FragmentTransaction.OP_UNSET_PRIMARY_NAV, fragment:old, fromExpandedOp:true), at: opNum)
                                    opNum+=1
                                    oldPrimaryNav = nil
                                }
                                let removeOp = Op(cmd: FragmentTransaction.OP_REMOVE, fragment: old, fromExpandedOp: true)
                                removeOp.mEnterAnim = op.mEnterAnim
                                removeOp.mPopEnterAnim = op.mPopEnterAnim
                                removeOp.mExitAnim = op.mExitAnim
                                removeOp.mPopExitAnim = op.mPopExitAnim
                                mOps.insert(removeOp, at: opNum)
                                added.remove(object: old)
                                opNum+=1;
                            }
                        }
                    }
                    if (alreadyAdded) {
                        mOps.remove(at: opNum)
                        opNum-=1
                    } else {
                        op.mCmd = FragmentTransaction.OP_ADD
                        op.mFromExpandedOp = true
                        added.append(f)
                    }
                break
            case FragmentTransaction.OP_SET_PRIMARY_NAV:
                    // It's ok if this is null, that means we will restore to no active
                    // primary navigation fragment on a pop.
                mOps.insert(Op(cmd: FragmentTransaction.OP_UNSET_PRIMARY_NAV, fragment: oldPrimaryNav, fromExpandedOp: true), at: opNum)
                op.mFromExpandedOp = true;
                opNum+=1;
                    // Will be set by the OP_SET_PRIMARY_NAV we inserted before when run
                oldPrimaryNav = op.mFragment;
                
                break
            default:
                break
            }
        }
        return oldPrimaryNav;
    }
    
    func trackAddedFragmentsInPop(added: inout Array<LuaFragment?>, oldPrimaryNav: inout LuaFragment?) -> LuaFragment?
    {
        for opNum in (0..<mOps.count).reversed() {
            let op = mOps[opNum]
            switch(op.mCmd) {
            case FragmentTransaction.OP_ADD:
                added.remove(object: op.mFragment)
                break
            case FragmentTransaction.OP_ATTACH:
                added.remove(object: op.mFragment)
                break
            case FragmentTransaction.OP_REMOVE:
                added.append(op.mFragment)
                break
            case FragmentTransaction.OP_DETACH:
                added.append(op.mFragment)
                break
            case FragmentTransaction.OP_UNSET_PRIMARY_NAV:
                oldPrimaryNav = op.mFragment
                break
            case FragmentTransaction.OP_SET_PRIMARY_NAV:
                oldPrimaryNav = nil
                break
            case FragmentTransaction.OP_SET_MAX_LIFECYCLE:
                op.mCurrentMaxState = op.mOldMaxState
                break
            default:
                break
            }
        }
        
        return oldPrimaryNav
    }
    
    func collapseOps() {
        let numOps = mOps.count
        for var opNum in (0..<numOps).reversed()
        {
            let op = mOps[opNum]
            if(!op.mFromExpandedOp) {
                continue
            }
            if(op.mCmd == FragmentTransaction.OP_SET_PRIMARY_NAV) {
                op.mFromExpandedOp = false
                mOps.remove(at: opNum - 1)
                opNum -= 1
            }
            else {
                let containerId = op.mFragment?.mContainerId
                op.mCmd = FragmentTransaction.OP_REPLACE
                op.mFromExpandedOp = false
                for replaceOpNum in (0..<opNum).reversed() {
                    let potentialReplaceOp = mOps[replaceOpNum]
                    if(potentialReplaceOp.mFromExpandedOp && potentialReplaceOp.mFragment?.mContainerId == containerId) {
                        mOps.remove(at: replaceOpNum)
                        opNum -= 1
                    }
                }
            }
        }
    }
    
    func getName() -> String? {
        return mName
    }
    
    override func isEmpty() -> Bool {
        return mOps.isEmpty == true
    }
        
}
