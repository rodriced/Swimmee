//
//  SignInView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 23/09/2022.
//

import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = CommonAccountViewModel()

    var body: some View {
        VStack {
            AppTitleView()

            Spacer()

            VStack(spacing: 30) {
                TextField("Email", text: $viewModel.email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .if(viewModel.emailError) {
                        $0.border(Color.red)
                    }

                SecureField("Password", text: $viewModel.password)
                    .if(viewModel.passwordError) {
                        $0.border(Color.red)
                    }

//                Picker("UserType", selection: $session.userTypeTest) {
//                    ForEach(UserType.allCases) { userType in
//                        Text(userType.rawValue.capitalized)
//                    }
//                }
//                .pickerStyle(.segmented)
            }
            .textFieldStyle(.roundedBorder)

            Spacer()

            Button {
                viewModel.signIn()
            } label: {
                if viewModel.submiting {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Sign in").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .opacity(viewModel.isReadyToSubmit ? 1 : 0.5)
            .keyboardShortcut(.defaultAction)

            NavigationLink("I have lost my password...", destination: Text("Lost password"))
        }
        .alert("Sign in Error", isPresented: $viewModel.errorAlertIsPresenting) {}
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
