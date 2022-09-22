import UIKit

@objc(FragmentManagerState)
open class FragmentManagerState: NSObject {
    var mSavedState: Array<FragmentStateStore>? = nil
    var mActive: Array<String>? = nil
    var mAdded: Array<String>? = nil
    var mBackStack: Array<BackStackRecordState>? = nil
    var mBackStackIndex: Int = 0
    var mPrimaryNavActiveWho: String? = nil
    var mBackStackStateKeys = Array<String>()
    var mBackStackStates = Array<BackStackState>()
    var mResultKeys = Array<String>()
    var mResults = Array<Dictionary<String, Any>>()
    var mLaunchedFragments = Array<LaunchedFragmentInfo>()
    
    override init() {
        
    }
}
