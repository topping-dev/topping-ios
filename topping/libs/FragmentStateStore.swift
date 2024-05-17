import UIKit

class FragmentStateStore: NSObject {
    var mWho: String?
    var mFromLayout: Bool
    var mFragmentId: String
    var mContainerId: String
    var mTag: String
    var mRetainInstance: Bool
    var mRemoving: Bool
    var mDetached: Bool
    var mArguments: LuaBundle
    var mHidden: Bool
    var mMaxLifecycleState: Int
    
    var mSavedFragmentState: LuaBundle?
    
    init(frag: LuaFragment) {
        mWho = frag.mWho
        mFromLayout = frag.mFromLayout
        mFragmentId = frag.mFragmentId
        mContainerId = frag.mContainerId
        mTag = frag.mTag
        mRetainInstance = frag.mRetainInstance
        mRemoving = frag.mRemoving
        mDetached = frag.mDetached
        mArguments = frag.mArguments
        mHidden = frag.mHidden
        mMaxLifecycleState = frag.mMaxState.rawValue
    }
    
    func instantiate(fragmentFactory: FragmentFactory) -> LuaFragment? {
        let fragment = fragmentFactory.instantiate()
        fragment?.mWho = mWho
        fragment?.mFromLayout = mFromLayout
        fragment?.mFragmentId = mFragmentId
        fragment?.mContainerId = mContainerId
        fragment?.mTag = mTag
        fragment?.mRetainInstance = mRetainInstance
        fragment?.mRemoving = mRemoving
        fragment?.mDetached = mDetached
        fragment?.mArguments = mArguments
        fragment?.mHidden = mHidden
        fragment?.mMaxState = LifecycleState(rawValue: mMaxLifecycleState)!
        if(mSavedFragmentState != nil) {
            fragment?.mSavedFragmentState = mSavedFragmentState
        }
        else {
            fragment?.mSavedFragmentState = LuaBundle()
        }
        return fragment
    }
}
