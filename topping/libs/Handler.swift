import Foundation

class Message {
    var what: Int
    var arg1: Int
    var arg2: Int
    var obj: Any?
    
    var replyTo: Any?
    
    let UID_NONE = -1
    var sendingUid = -1
    var workSourceUid = -1
    
    static let FLAG_IN_USE = 1 << 0
    static let FLAG_ASYNCHRONOUS = 1 << 1
    static let FLAGS_TO_CLEAR_ON_COPY_FROM = FLAG_IN_USE
    var flags = 0
    var when = 0
    
    var data: Dictionary<String, Any>?
    var target: Handler?
    var callback: Runnable?
    var next: Message?
    
    static var sPoolSync = NSObject()
    static var sPool: Message? = nil
    static var sPoolSize = 0
    
    static let MAX_POOL_SIZE = 50
    static var gCheckRecycle = true
    
    init() {

    }
    
    static func obtain() -> Message {
        return syncedRet(sPoolSize) {
            if(sPool != nil) {
                var m = sPool
                sPool = m?.next
                m?.next = nil
                m?.flags = 0
                sPoolSize -= 1
                if(m != nil) {
                    return m
                }
                else {
                    return Message()
                }
            }
        } as! Message
    }
    
    static func obtain(orig: Message) -> Message {
        var m = obtain()
        m.what = orig.what
        m.arg1 = orig.arg1
        m.arg2 = orig.arg2
        m.obj = orig.obj
        m.replyTo = orig.replyTo
        m.sendingUid = orig.sendingUid
        m.workSourceUid = orig.workSourceUid
        if(orig.data != nil) {
            m.data = Dictionary(_immutableCocoaDictionary: orig.data)
        }
        m.target = orig.target
        m.callback = orig.callback
        
        return m
        return syncedRet(sPoolSize) {
            if(sPool != nil) {
                var m = sPool
                sPool = m?.next
                m?.next = nil
                m?.flags = 0
                sPoolSize -= 1
                if(m != nil) {
                    return m
                }
                else {
                    return Message()
                }
            }
        } as! Message
    }
    
    static func obtain(h: Handler) -> Message {
        var m = obtain()
        m.target = h
        
        return m
    }
    
    static func obtain(h: Handler, callback: Runnable) -> Message {
        var m = obtain()
        m.target = h
        m.callback = callback
        
        return m
    }
    
    static func obtain(h: Handler, what: Int) -> Message {
        var m = obtain()
        m.target = h
        m.what = what
        
        return m
    }
    
    static func obtain(h: Handler, what: Int, obj: Any) -> Message {
        var m = obtain()
        m.target = h
        m.what = what
        m.obj = obj
        
        return m
    }
    
    static func obtain(h: Handler, what: Int, arg1: Int, arg2: Int) -> Message {
        var m = obtain()
        m.target = h
        m.what = what
        m.arg1 = arg1
        m.arg2 = arg2
        
        return m
    }
    
    static func obtain(h: Handler, what: Int, arg1: Int, arg2: Int, obj: Any) -> Message {
        var m = obtain()
        m.target = h
        m.what = what
        m.arg1 = arg1
        m.arg2 = arg2
        m.obj = obj
        
        return m
    }
    
    func recycle() {
        if(isInUse()) {
            return
        }
        recycleUnchecked()
    }
    
    func recycleUnchecked() {
        flags = Message.FLAG_IN_USE
        what = 0
        arg1 = 0
        arg2 = 0
        obj = nil
        replyTo = nil
        sendingUid = -1
        workSourceUid = -1
        when = 0
        target = nil
        callback = nil
        data = nil
        
        synced(Message.sPoolSync) {
            if(Message.sPoolSize < Message.MAX_POOL_SIZE) {
                next = Message.sPool
                Message.sPool = self
                Message.sPoolSize += 1
            }
        }
    }
    
    func copyFrom(o: Message) {
        self.flags = o.flags & ~Message.FLAGS_TO_CLEAR_ON_COPY_FROM
        self.what = o.what
        self.arg1 = o.arg1
        self.arg2 = o.arg2
        self.obj = o.obj
        self.replyTo = o.replyTo
        self.sendingUid = o.sendingUid
        self.workSourceUid = o.workSourceUid
        if(o.data != nil) {
            self.data = Dictionary(_immutableCocoaDictionary: o.data)
        } else {
            self.data = nil
        }
    }
    
    func getWhen() -> Int {
        return when
    }
    
    func setTarget(target: Handler?) {
        self.target = target
    }
    
    func getTarget() -> Handler? {
        return self.target
    }
    
    func getCallback() -> Runnable? {
        return callback
    }
    
    func setCallback(r: Runnable?) -> Message {
        callback = r
        return self
    }
    
    func getData() -> Dictionary<String, Any> {
        if(data == nil) {
            data = Dictionary()
        }
        return data!
    }
    
    func peekData() -> Dictionary<String, Any>? {
        return data
    }
    
    func setData(data: Dictionary<String, Any>) {
        self.data = data
    }
    
    func setWhat(what: Int) -> Message {
        self.what = what
        return self
    }
    
    func sendToTarget() {
        target.sendMessage(self)
    }
    
    func isAsynchronous() -> Bool {
        return flags & Message.FLAG_ASYNCHRONOUS > 0
    }
    
    func setAsynchronous(async: Bool) {
        if(async) {
            flags |= Message.FLAG_ASYNCHRONOUS
        } else {
            flags &= ~Message.FLAG_ASYNCHRONOUS
        }
    }
    
    func isInUse() -> Bool {
        return ((flags & Message.FLAG_IN_USE) == Message.FLAG_IN_USE)
    }
    
    func markInUse() {
        flags |= Message.FLAG_IN_USE
    }
}

protocol Callback {
    func handleMessage(msg: Message) -> Bool
}

class Handler {
    
    var mLooper: DispatchQueue? = nil
    var mQueue: DispatchQueue? = nil
    var mCallback: Callback? = nil
    var mAsynchronous: Bool = false
    static var MAIN_THREAD_HANDLER : Handler? = nil
    
    init() {
        mLooper = DispatchQueue.global() //current?
        mQueue = mLooper
        mCallback = callback
        mAsynchronous = false
    }
    
    convenience init(callback: Callback?) {
        self.init(callback: callback, asyn: false)
    }
    
    convenience init(dispatchQueue: DispatchQueue) {
        self.init(looper: dispatchQueue, callback: nil, asyn: false)
    }
    
    convenience init(dispatchQueue: DispatchQueue, callback: Callback) {
        self.init(looper: dispatchQueue, callback: callback, asyn: false)
    }
    
    convenience init(async: Bool) {
        self.init(callback: nil, asyn: async)
    }
    
    init(callback: Callback?, asyn: Bool) {
        mLooper = DispatchQueue.global() //current?
        mQueue = mLooper
        mCallback = callback
        mAsynchronous = async
    }
    
    init(looper: DispatchQueue, callback: Callback?, asyn: Bool) {
        mLooper = looper
        mQueue = looper
        mCallback = callback
        mAsynchronous = async
    }
    
    func handleMessage(msg: Message) {
        
    }
    
    func dispatchMessage(msg: Message) {
        if(msg.callback != nil) {
            handleCallback(msg: msg)
        } else {
            if(mCallback != nil) {
                if(mCallback.handleMessage(msg: msg)) {
                    return
                }
            }
            handleMessage(msg: msg)
        }
    }
    
    static func createAsync(looper: DispatchQueue, callback: Callback) -> Handler {
        return Handler(looper: looper, callback: callback, asyn: true)
    }
    
    static func getMain() -> Handler {
        if(Handler.MAIN_THREAD_HANDLER != nil) {
            Handler.MAIN_THREAD_HANDLER = Handler(dispatchQueue: DispatchQueue.main)
        }
        return Handler.MAIN_THREAD_HANDLER!
    }
    
    static func mainIfNull(handler: Handler?) -> Handler? {
        return handler == nil ? getMain() : handler
    }
    
    func obtainMessage() -> Message {
        return Message.obtain(h: self)
    }
    
    func obtainMessage(what: Int) -> Message {
        return Message.obtain(h: self, what: what)
    }
    
    func obtainMessage(what: Int, obj: Any) -> Message {
        return Message.obtain(h: self, what: what, obj: obj)
    }
    
    func obtainMessage(what: Int, arg1: Int, arg2: Int) -> Message {
        return Message.obtain(h: self, what: what, arg1: arg1, arg2: arg2)
    }
    
    func obtainMessage(what: Int, arg1: Int, arg2: Int, obj: Any) -> Message {
        return Message.obtain(h: self, what: what, arg1: arg1, arg2: arg2, obj: obj)
    }
    
    func post(r: Runnable?) -> Bool {
        return sendMessageDelayed(getPostMessage(r: r), 0)
    }
    
    func postAtTime(r: Runnable?, uptimeMillis: Int) -> Bool {
        return sendMessageAtTime(getPostMessage(r, token), uptimeMillis)
    }
    
    func postDelayed(r: Runnable?, delayMillis: Int) -> Bool {
        return sendMessageDelayed(getPostMessage(r), delayMillis)
    }
    
    func postDelayed(r: Runnable?, what: Int, delayMillis: Int) -> Bool {
        return sendMessageDelayed(getPostMessage(r).setWhat(what: what), delayMillis)
    }
    
    func postDelayed(r: Runnable, token: Any?, delayMillis: Int) -> Bool {
        return sendMessageDelayed(getPostMessage(r, token), delayMillis)
    }
    
    func postAtFrontOfQueue(r: Runnable) -> Bool {
        return sendMessageAtFrontOfQueue(getPostMessage(r))
    }
    
    func runWithScissors(r: Runnable?, timeout: Int) -> Bool {
        if(r == nil) {
            return false
        }
        if(timeout < 0) {
            return false
        }
        
        do {
            try dispatchPrecondition(condition: .onQueue(mLooper))
        } catch {
            var br = BlockingRunnable(r)
            return br.postAndWait(self, timeout)
        }
        
        r?.run()
        return true
    }
    
    func removeCallbacks(r: Runnable) {
        //mQueue
    }
    
    func sendMessage(msg: Message) -> Bool {
        return sendMessageDelayed(msg: msg, 0)
    }
    
    func sendEmptyMessage(what: Int) -> Bool {
        return sendEmptyMessageDelayed(what: what, 0)
    }
    
    func sendEmptyMessageDelayed(what: Int, uptimeMillis: Int)
}
