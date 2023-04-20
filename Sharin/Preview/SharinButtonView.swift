//
//  SharinButtonView.swift
//  Sharin
//
//  Created by 서광현 on 2023/04/20.
//

import SwiftUI

struct SharinButtonView: UIViewRepresentable {
    typealias UIViewType = UIButton
    
    func makeUIView(context: Context) -> UIButton {
        let button = SharinButton(systemName: "xmark")
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        //
    }
}

struct SharinButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SharinButtonView()
    }
}
