//
//  UserCellView.swift
//  Swimmee
//
//  Created by Rodolphe Desruelles on 21/11/2022.
//

import SDWebImageSwiftUI
import SwiftUI

struct UserCellView: View {
    let profile: Profile

    var body: some View {
        HStack(spacing: 20) {
            Group {
                if let photoUrl = profile.photoUrl {
                    WebImage(url: photoUrl)
                        .resizable()
                        .placeholder(Image(systemName: "ProfilePhoto"))
                        .scaledToFill()
//                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("ProfilePhoto")
                        .resizable()
                }
            }
            .frame(width: 60, height: 60).cornerRadius(8)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(profile.fullname)").font(.title2)
                Text("\(profile.email)").font(.callout)
            }
            //                .padding(EdgeInsets(leading:10 ))
        }
    }
}

struct UserCellView_Previews: PreviewProvider {
    static var previews: some View {
        UserCellView(profile: Profile.coachSample)
    }
}
