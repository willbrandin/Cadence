import SwiftUI
import ComposableArchitecture
import Models

extension MileageStatus {
    var animationValue: Float {
        switch self {
        case .great:
            return 0.1
        case .good:
            return 0.2
        case .okay:
            return 0.5
        case .maintenanceRecommended:
            return 0.8
        case .maintenceNeeded:
            return 1.0
        }
    }
}

typealias MileageAnimationReducer = Reducer<MileageAnimationState, MileageAnimationAction, MileageAnimationEnvironment>

struct MileageAnimationState: Equatable {
    var width: CGFloat = 200 // Todo: Remove from state -> View only
    var animationDidStart = false
    var mileageStatus: MileageStatus = .great
    var value: Float = MileageStatus.great.animationValue
}

enum MileageAnimationAction: Equatable {
    case cancel
    case viewLoaded
    case setStatus(MileageStatus)
    case startAnimation
}

struct MileageAnimationEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue> = .main
}

let mileageAnimationReducer = MileageAnimationReducer
{ state, action, environment in
    struct MileageAnimationCancelId: Hashable {}
    
    switch action {
        
    case .cancel:
        return .cancel(id: MileageAnimationCancelId())
        
    case let .setStatus(status):
        state.value = status.animationValue
        state.mileageStatus = status
        return .none
        
    case .startAnimation:
        state.animationDidStart = true
        return .keyFrames(
            values: MileageStatus.allCases
                .map { (output: .setStatus($0), duration: 0.6) },
            scheduler: environment.mainQueue.animation(.interactiveSpring())
        )
        .cancellable(id: MileageAnimationCancelId())
        
    case .viewLoaded:
        guard !state.animationDidStart
        else { return .none }
        
        return Effect(value: .startAnimation)
            .delay(for: 0.5, scheduler: environment.mainQueue)
            .eraseToEffect()
    }
}

struct MileageAnimationView: View {
    
    
    let store: Store<MileageAnimationState, MileageAnimationAction>
    @ObservedObject var viewStore: ViewStore<MileageAnimationState, MileageAnimationAction>
    
    init(
        store: Store<MileageAnimationState, MileageAnimationAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(viewStore.mileageStatus.title)
                .font(.title3)
                .bold()
                .minimumScaleFactor(0.5)
                .padding(.bottom, 2)
                .frame(alignment: .center)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 33, style: .continuous)
                    .frame(width: viewStore.width, height: 12)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.lightGray))

                RoundedRectangle(cornerRadius: 33, style: .continuous)
                    .frame(width: min(CGFloat(viewStore.value) * viewStore.width, viewStore.width), height: 12)
                    .foregroundColor(viewStore.mileageStatus.statusColor)
            }
        }
        .frame(width: viewStore.width)
        .onAppear {
            viewStore.send(.viewLoaded, animation: .linear)
        }
    }
}

struct MileageAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        MileageAnimationView(
            store: Store(
                initialState: MileageAnimationState(),
                reducer: mileageAnimationReducer,
                environment: MileageAnimationEnvironment()
            )
        )
    }
}
