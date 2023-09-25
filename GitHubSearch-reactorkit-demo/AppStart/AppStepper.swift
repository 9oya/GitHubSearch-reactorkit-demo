//
//  AppStepper.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/25/23.
//

import RxSwift
import RxCocoa
import RxFlow

class AppStepper: Stepper {
    
    let steps = PublishRelay<Step>()
    private let serviceProvider: ServiceProviderProtocol
    
    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
    }
    
    var initialStep: Step {
        return AppSteps.homeIsRequired
    }
}
