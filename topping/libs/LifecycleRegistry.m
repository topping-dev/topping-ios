#import "LifecycleRegistry.h"

@implementation ObserverWithState

-(void)dispatchEvent:(id<LifecycleOwner>)owner :(LifecycleEvent)event
{
    LifecycleState newState = [Lifecycle getTargetState:event];
    self.state = [LifecycleRegistry min:self.state :newState];
    if([self.observer respondsToSelector:@selector(onStateChanged::)])
        [self.observer onStateChanged:owner :event];
    self.state = newState;
}

@end

@implementation LifecycleRegistry

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mObserverMap = [[MutableOrderedDictionary alloc] init];
        self.mAddingObserverCounter = 0;
        self.mHandlingEvent = false;
        self.mNewEventOccurred = false;
    }
    return self;
}

-(id) initWithOwner:(id<LifecycleOwner>)owner
{
    self = [self init];
    if(self)
    {
        self.mLifecycleOwner = owner;
        self.mState = LIFECYCLESTATE_INITIALIZED;
        self.mEnforceMainThread = true;
    }
    return self;
}

-(void)markState:(LifecycleState)state
{
    [self enforceMainThreadIfNeeded:@"markState"];
    [self setCurrentState:state];
}

-(void)setCurrentState:(LifecycleState)state
{
    [self enforceMainThreadIfNeeded:@"setCurrentState"];
    [self moveToState:state];
}

-(void)handleLifecycleEvent:(LifecycleEvent) event
{
    [self enforceMainThreadIfNeeded:@"handleLifecycleEvent"];
    [self moveToState:[Lifecycle getTargetState:event]];
}

-(void)moveToState:(LifecycleState)next
{
    if (self.mState == next) {
        return;
    }
    self.mState = next;
    if (self.mHandlingEvent || self.mAddingObserverCounter != 0) {
        self.mNewEventOccurred = true;
        // we will figure out what to do on upper level.
        return;
    }
    self.mHandlingEvent = true;
    [self sync];
    self.mHandlingEvent = false;
}

-(BOOL)isSynced
{
     if([self.mObserverMap count] == 0)
        return true;
    
    NSArray *keys = [self.mObserverMap allKeys];
    LifecycleState eldestObserverState = ((ObserverWithState*)[self.mObserverMap objectForKey:[keys objectAtIndex:0]]).state;
    LifecycleState newestObserverState = ((ObserverWithState*)[self.mObserverMap objectForKey:[keys objectAtIndex:keys.count - 1]]).state;
    
    return eldestObserverState == newestObserverState && self.mState ==newestObserverState;
}

-(LifecycleState)calculateTargetState:(LuaLifecycleObserver*) observer
{
    ObserverWithState *previous = [self.mObserverMap ceil:observer];
    LifecycleState siblingState = previous != nil ? previous.state : LIFECYCLESTATE_NIL;
    LifecycleState parentState = self.mParentStates.count != 0 ? [[self.mParentStates lastObject] intValue] : LIFECYCLESTATE_NIL;
    return [LifecycleRegistry min:[LifecycleRegistry min:self.mState :siblingState] :parentState];
}

-(void) addObserver:(LuaLifecycleObserver *)observer {
    [self enforceMainThreadIfNeeded:@"addObserver"];
    LifecycleState initialState = self.mState == LIFECYCLESTATE_DESTROYED ? LIFECYCLESTATE_DESTROYED : LIFECYCLESTATE_INITIALIZED;
    
    ObserverWithState *statefulObserver = [[ObserverWithState alloc] init];
    statefulObserver.observer = observer;
    statefulObserver.state = initialState;
    ObserverWithState *previous = [self.mObserverMap putIfAbsent:observer :statefulObserver];
    
    if(previous != nil)
        return;
    
    if(self.mLifecycleOwner == nil)
        return;
    
    BOOL isReentrance = self.mAddingObserverCounter != 0 || self.mHandlingEvent;
    LifecycleState targetState = [self calculateTargetState:observer];
    self.mAddingObserverCounter++;
    while (statefulObserver.state < targetState && [self.mObserverMap objectForKey:observer]) {
        [self pushParentState:statefulObserver.state];
        LifecycleEvent event = [Lifecycle upFrom:statefulObserver.state];
        if(event == LIFECYCLEEVENT_NIL)
            return;
        [statefulObserver dispatchEvent:self.mLifecycleOwner: event];
        [self popParentState];
        targetState = [self calculateTargetState:observer];
    }
    if(!isReentrance) {
        [self sync];
    }
    self.mAddingObserverCounter--;
}
                     
-(void)popParentState
{
    [self.mParentStates removeLastObject];
}

-(void)pushParentState:(LifecycleState)state
{
    [self.mParentStates addObject:[NSNumber numberWithInt:state]];
}
                     
-(void)removeObserver:(LuaLifecycleObserver*) observer {
    [self enforceMainThreadIfNeeded:@"removeObserver"];
    
    /**
     // we consciously decided not to send destruction events here in opposition to addObserver.
     // Our reasons for that:
     // 1. These events haven't yet happened at all. In contrast to events in addObservers, that
     // actually occurred but earlier.
     // 2. There are cases when removeObserver happens as a consequence of some kind of fatal
     // event. If removeObserver method sends destruction events, then a clean up routine becomes
     // more cumbersome. More specific example of that is: your LifecycleObserver listens for
     // a web connection, in the usual routine in OnStop method you report to a server that a
     // session has just ended and you close the connection. Now let's assume now that you
     // lost an internet and as a result you removed this observer. If you get destruction
     // events in removeObserver, you should have a special case in your onStop method that
     // checks if your web connection died and you shouldn't try to report anything to a server.
     mObserverMap.remove(observer);
     */
    [self.mObserverMap removeObjectForKey:observer];
}

-(NSUInteger)getObserverCount {
    [self enforceMainThreadIfNeeded:@"getObserverCount"];
    return self.mObserverMap.count;
}

-(LifecycleState)getCurrentState {
    return self.mState;
}

-(void) forwardPass:(id<LifecycleOwner>) lifecycleOwner {
    NSEnumerator *ascendingIterator = [self.mObserverMap keyEnumerator];
    id key;
    while((key = [ascendingIterator nextObject]) != nil && !self.mNewEventOccurred)
    {
        ObserverWithState *observer = [self.mObserverMap objectForKey:key];
        while (observer.state < self.mState && !self.mNewEventOccurred && [self.mObserverMap objectForKey:key]) {
            [self pushParentState:observer.state];
            LifecycleEvent event = [Lifecycle upFrom:observer.state];
            if(event == LIFECYCLEEVENT_NIL)
                return;
            [observer dispatchEvent:lifecycleOwner :event];
            [self popParentState];
        }
    }
}

-(void) backwardPass:(id<LifecycleOwner>) lifecycleOwner {
    NSEnumerator *descendingIterator = [self.mObserverMap reverseKeyEnumerator];
    id key;
    while((key = [descendingIterator nextObject]) != nil && !self.mNewEventOccurred)
    {
        ObserverWithState *observer = [self.mObserverMap objectForKey:key];
        while (observer.state > self.mState && !self.mNewEventOccurred && [self.mObserverMap objectForKey:key]) {
            LifecycleEvent event = [Lifecycle downFrom:observer.state];
            if(event == LIFECYCLEEVENT_NIL)
                return;
            [self pushParentState:[Lifecycle getTargetState:event]];
            [observer dispatchEvent:lifecycleOwner :event];
            [self popParentState];
        }
    }
}

-(void) sync {
    id<LifecycleOwner> lifecycleOwner = self.mLifecycleOwner;
    if(lifecycleOwner == nil)
        return;
    while (![self isSynced]) {
        self.mNewEventOccurred = false;
        if(self.mState < ((ObserverWithState*)[self.mObserverMap eldest]).state)
            [self backwardPass:lifecycleOwner];
        ObserverWithState *newest = [self.mObserverMap newest];
        if(!self.mNewEventOccurred && newest != nil && self.mState > newest.state)
            [self forwardPass:lifecycleOwner];
    }
    self.mNewEventOccurred = false;
}

-(void)enforceMainThreadIfNeeded:(NSString*) methodName {
    if(self.mEnforceMainThread)
    {
        if(![NSThread isMainThread])
        {
            [NSException raise:@"Illegal State" format:@"method %@ must be called on the main thread", methodName];
        }
    }
}

+(LifecycleState)min:(LifecycleState)state1 :(LifecycleState)state2 {
    return state2 != LIFECYCLESTATE_NIL && state2 <state1 ? state2 : state1;
}

@end
