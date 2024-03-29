//
//  SwimmerCoachViewModelTests.swift
//  SwimmeeTests
//
//  Created by Rodolphe Desruelles on 11/12/2022.
//

@testable import Swimmee

import Combine
import Foundation
import XCTest

final class SwimmerCoachViewModelTests: XCTestCase {
    struct TestData: Equatable {
        let state: SwimmerCoachViewModel.ViewState
        let coachs: [Profile]
        let selectedCoach: Profile?
                
        init(_ data: (SwimmerCoachViewModel.ViewState, [Profile], Profile?)) {
            self.state = data.0
            self.coachs = data.1
            self.selectedCoach = data.2
        }
    }
    
    func testWhenCoachsListLoadedIsEmpty_ThenStateIsInfoWithMessage() {
        for selectedCoach in [Samples.aCoachProfile, nil] {
            let anEmptyCoachsList: [Profile] = []
            
            let profileAPI = MockProfileAPI()
            profileAPI.mockLoadCoachs = { anEmptyCoachsList }
            
            let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
            
            XCTAssertEqual(sut.state, .loading)
            
            assertPublishedValue(
                Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
                equals: TestData((.info("No coach available for now.\nCome back later."), [], nil))
            ) {
                Task {
                    await sut.loadCoachs(withSelected: selectedCoach?.userId)
                }
            }
        }
    }

    func testWhenCoachsListLoadingFinishesWithError_ThenStateIsInfoWithMessage() {
        for selectedCoach in [Samples.aCoachProfile, nil] {
            let profileAPI = MockProfileAPI()
            profileAPI.mockLoadCoachs = { throw TestError.fakeNetworkError }
            
            let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
            
            XCTAssertEqual(sut.state, .loading)
            
            assertPublishedValue(
                Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
                equals: TestData((.info("fakeNetworkError"), [], nil))
            ) {
                Task {
                    await sut.loadCoachs(withSelected: selectedCoach?.userId)
                }
            }
        }
    }
    
    func testWhenCoachsListIsLoadedWithNoSelectedOne_ThenStateIsNorma() {
        let aCoachsList = Samples.aCoachsList
            
        let profileAPI = MockProfileAPI()
        profileAPI.mockLoadCoachs = {
            aCoachsList
        }
            
        let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
            
        XCTAssertEqual(sut.state, .loading)
            
        assertPublishedValue(
            Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
            equals: TestData((.normal, aCoachsList, nil))
        ) {
            Task {
                await sut.loadCoachs(withSelected: nil)
            }
        }
    }
    
    func testWhenCoachsListIsLoadedWithASelectedOne_ThenStateIsNorma() {
        let aCoachsList = Samples.aCoachsList
        let selectedCoach = aCoachsList[3]
            
        let profileAPI = MockProfileAPI()
        profileAPI.mockLoadCoachs = {
            aCoachsList
        }
            
        let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
            
        XCTAssertEqual(sut.state, .loading)
            
        assertPublishedValue(
            Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
            equals: TestData((.normal, aCoachsList, selectedCoach))
        ) {
            Task {
                await sut.loadCoachs(withSelected: selectedCoach.userId)
            }
        }
    }

    func testWhenCoachsListIsLoadedWithACoachNotInTheList_ThenStateIsInfoWithErrorMessage() {
        let aCoachsList = Samples.aCoachsList
        let selectedCoach = Samples.aCoachProfile
            
        let profileAPI = MockProfileAPI()
        profileAPI.mockLoadCoachs = {
            aCoachsList
        }
            
        let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
            
        XCTAssertEqual(sut.state, .loading)
            
        assertPublishedValue(
            Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
            equals: TestData((.info("Can't find your coach in the list of available coachs.\nCome back later or ask administration for help."), [], nil))
        ) {
            Task {
                await sut.loadCoachs(withSelected: selectedCoach.userId)
            }
        }
    }
    
    func testGivenSelectedCoach_WhenSavingNone_ThenCoachIsRemoved() {
        let aCoachsList = Samples.aCoachsList
        let selectedCoach = aCoachsList[3]
            
        let profileAPI = MockProfileAPI()
        profileAPI.mockUpdateCoach = {}
            
        let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
        sut.coachs = aCoachsList
        sut.currentCoach = selectedCoach
        sut.state = .normal
                        
        assertPublishedValue(
            Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
            equals: TestData((.normal, aCoachsList, nil))
        ) {
            sut.saveSelectedCoach(nil)
        }
    }
    
    func testGivenNoSelectedCoach_WhenSavingNewOne_ThenCoachIsSelected() {
        let aCoachsList = Samples.aCoachsList
        let newSelectedCoach = aCoachsList[3]
            
        let profileAPI = MockProfileAPI()
        profileAPI.mockUpdateCoach = {}
            
        let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
        sut.coachs = aCoachsList
        sut.currentCoach = nil
        sut.state = .normal
                        
        assertPublishedValue(
            Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
            equals: TestData((.normal, aCoachsList, newSelectedCoach))
        ) {
            sut.saveSelectedCoach(newSelectedCoach)
        }
    }

    func testGivenSelectedCoach_WhenSavingANewOne_ThenCoachIsReplaced() {
        let aCoachsList = Samples.aCoachsList
        let selectedCoach = aCoachsList[3]
        let newSelectedCoach = aCoachsList[4]

        let profileAPI = MockProfileAPI()
        profileAPI.mockUpdateCoach = {}
            
        let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
        sut.coachs = aCoachsList
        sut.currentCoach = selectedCoach
        sut.state = .normal
                        
        assertPublishedValue(
            Publishers.CombineLatest3(sut.$state, sut.$coachs, sut.$currentCoach).map(TestData.init),
            equals: TestData((.normal, aCoachsList, newSelectedCoach))
        ) {
            sut.saveSelectedCoach(newSelectedCoach)
        }
    }
    
    func testGivenSelectedCoach_WhenSavingWithANetworkError_ThenAlertAppear() {
        let aCoachsList = Samples.aCoachsList
        let selectedCoach = aCoachsList[3]
            
        let profileAPI = MockProfileAPI()
        profileAPI.mockUpdateCoach = { throw TestError.fakeNetworkError }
            
        let sut = SwimmerCoachViewModel(profileAPI: profileAPI)
        sut.coachs = aCoachsList
        sut.currentCoach = selectedCoach
        sut.state = .normal
                        
        assertPublishedValue(
            sut.alertContext.$isPresented,
            equals: true
        ) {
            sut.saveSelectedCoach(nil)
        }
        
        XCTAssertEqual(sut.alertContext.message, "fakeNetworkError")
    }
    
    func testConfirmationsPresentation() {
        let coach1 = Samples.aProfile(of: .coach, ref: 1)
        let coach2 = Samples.aProfile(of: .coach, ref: 2)

        let sut = SwimmerCoachViewModel(profileAPI: MockProfileAPI())
        
        XCTAssertEqual(sut.confirmationPresented, false)
        
        sut.presentSubscribeConfirmation(coach: coach1)
        XCTAssertEqual(sut.confirmationPresented, true)
        XCTAssertEqual(sut.confirmation.message, "You are going to subcribe to \(coach1.fullname).")

        sut.confirmationPresented = false
        XCTAssertEqual(sut.confirmation.message, "")

        sut.presentUnsubscribeConfirmation(coach: coach1)
        XCTAssertEqual(sut.confirmationPresented, true)
        XCTAssertEqual(sut.confirmation.message, "You are going to unsubcribe from \(coach1.fullname).")

        sut.confirmationPresented = false
        XCTAssertEqual(sut.confirmation.message, "")
        
        sut.presentReplaceConfirmation(currentCoach: coach1, newCoach: coach2)
        XCTAssertEqual(sut.confirmationPresented, true)
        XCTAssertEqual(sut.confirmation.message, "You are going to unsubcribe from \(coach1.fullname) and subscribe to \(coach2.fullname).")
    }
}
