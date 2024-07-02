
import UIKit
import RxSwift
import RxCocoa

@dynamicMemberLookup
struct DynamicWrapperView<View: AnyObject> {
    
    let view: View
    
    init(_ view: View) {
        self.view = view
    }
    
    public subscript<Property>(
        dynamicMember keyPath: KeyPath<View, Property>
    ) -> Reactive<Property> where Property: NSObject
    {
        view[keyPath: keyPath].rx
    }
}

@propertyWrapper
struct DynamicBehaviorWrapper<Property> {
    
    private var subject: BehaviorSubject<Property>
    var defaultValue: Property
    
    init(wrappedValue: Property) {
        self.subject = BehaviorSubject(value: wrappedValue)
        self.defaultValue = wrappedValue
    }
    
    var wrappedValue: Property {
        get {
            // 현재 값 반환
            if let value = try? subject.value() {
                return value
            } else {
                return defaultValue
            }
        }
        set {
            // 새로운 값 방출
            subject.onNext(newValue)
        }
    }
    
    var projectedValue: Observable<Property> {
        subject.asObservable()
    }
}


@propertyWrapper
struct DynamicPublishWrapper<Property> {
    
    private var subject: PublishSubject<Property>
    
    init() {
        self.subject = PublishSubject<Property>()
    }
    
    var wrappedValue: Property {
        get {
            fatalError("GET을 지원하지 않는 Wrapper 입니다.")
        }
        set {
            subject.onNext(newValue)
        }
    }
    
    var projectedValue: Observable<Property> {
        subject.asObservable()
    }
}
