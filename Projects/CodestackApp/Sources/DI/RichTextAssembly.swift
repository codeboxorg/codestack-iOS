
import Swinject
import Domain


public struct RichTextAssembly: Assembly {
    
    public func assemble(container: Container) {
        container.register(RichTextViewController<MyPostingActionButtonGroup>.self) { resolver, markdown, storeVO, viewType in
            let firebaseUsecase = resolver.resolve(FirebaseUsecase.self)!
            let dependency = RichTextViewController.Dependency(
                html: markdown,
                storeVO: storeVO,
                usecase: firebaseUsecase,
                viewType: viewType,
                group: MyPostingActionButtonGroup()
            )
            let vc = RichTextViewController<MyPostingActionButtonGroup>.create(with: dependency)
            return vc
        }
        
        container.register(RichTextViewController<OtherPostingActionButtonGroup>.self) { resolver, markdown, storeVO, viewType in
            let firebaseUsecase = resolver.resolve(FirebaseUsecase.self)!
            let dependency = RichTextViewController.Dependency(
                html: markdown,
                storeVO: storeVO,
                usecase: firebaseUsecase,
                viewType: viewType,
                group: OtherPostingActionButtonGroup()
            )
            let vc = RichTextViewController<OtherPostingActionButtonGroup>.create(with: dependency)
            return vc
        }
        
        container.register(RichTextViewController<MyTempPostingActionButtonGroup>.self) { resolver, markdown, storeVO, viewType in
            let firebaseUsecase = resolver.resolve(FirebaseUsecase.self)!
            let dependency = RichTextViewController.Dependency(
                html: markdown,
                storeVO: storeVO,
                usecase: firebaseUsecase,
                viewType: viewType,
                group: MyTempPostingActionButtonGroup()
            )
            let vc = RichTextViewController<MyTempPostingActionButtonGroup>.create(with: dependency)
            return vc
        }
        
        container.register(RichTextViewController<PreviewsActionButtonGroup>.self) { resolver, markdown, storeVO, viewType in
            let firebaseUsecase = resolver.resolve(FirebaseUsecase.self)!
            let dependency = RichTextViewController.Dependency(
                html: markdown,
                storeVO: storeVO,
                usecase: firebaseUsecase,
                viewType: viewType,
                group: PreviewsActionButtonGroup()
            )
            let vc = RichTextViewController<PreviewsActionButtonGroup>.create(with: dependency)
            return vc
        }
    }
}


