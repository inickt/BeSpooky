//
//  RoleSelectionView.swift
//  BeSpooky
//
//  Created by Nick Thompson on 10/22/22.
//

import SwiftUI

struct RoleSelectionView: View {
    var body: some View {
        NavigationView {
            List(Role.allCases) { role in
                NavigationLink {
                    role.navigationView

                } label: {
                    Text(role.description)
                }
            }
            .navigationTitle("BeSpooky")
        }
    }
}

extension Role {
    var description: String {
        switch self {
        case .remote:
            return "Remote"
        case .frontPreview:
            return "Front Preview"
        case .rearCamera:
            return "Rear Camera"
        }
    }

    @ViewBuilder var navigationView: some View {
        switch self {
        case .remote:
            RemoteView()
        case .frontPreview:
            FrontPreviewView()
        case .rearCamera:
            RearCameraView()
        }
    }

    var hidesNavigation: Bool {
        switch self {
        case .frontPreview:
            return true
        case .remote, .rearCamera:
            return false
        }
    }
}
