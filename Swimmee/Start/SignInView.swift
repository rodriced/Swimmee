//
//  SignInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""

    func authenticateUser() -> Profile? {
        Profile(userType: .swimmer, firstName: "Max", lastName: "Laroche", email: "max.laroche@ggmail.com")
    }
}

struct SignInView: View {
    @EnvironmentObject var session: Session

    @StateObject var viewModel = SignInViewModel()
//    @State var userTypeTest = UserType.coach

    var body: some View {
        VStack {
            AppTitleView()

            Spacer()

            VStack(spacing: 30) {
                TextField("Email", text: $viewModel.email)
                SecureField("Password", text: $viewModel.password)
                
                Picker("UserType", selection: $session.userTypeTest) {
                    ForEach(UserType.allCases) { userType in
                        Text(userType.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
            }
            .textFieldStyle(.roundedBorder)

            Spacer()

            Button { session.userProfile = viewModel.authenticateUser() }
                label: {
                    Text("Sign in").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)

            NavigationLink("I have lost my password...", destination: Text("Lost password"))
        }
        .padding()
        .navigationBarTitle("Sign In", displayMode: .inline)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(Session())
    }
}
