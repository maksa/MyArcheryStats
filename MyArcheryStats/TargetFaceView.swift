//
//  ContentView.swift
//  MyArcheryStats
//
//  Created by Milan Maksimovic on 22.6.23..
//

import SwiftUI

struct MarkerView : View {
    var body: some View {
        Image(systemName: "plus").resizable().frame(width: 30, height:30).foregroundColor(Color("Marker"))
    }
}

struct TargetFaceView: View {
    @GestureState private var location: CGPoint = .zero
    @State var markerLocation : CGPoint = .zero
    var lineWidth = 0.5
    var colors : [Color] = [ .white, .white, .black, .black, .blue, .blue, .red, .red, .yellow, .yellow, .yellow, .yellow ]
    var bordercolors : [Color] = [ .black, .black, .black, .white, .black, .black, .black, .black, .black, .black, .black, .black]
    @State var scale = 1.0
    
    func widthFromGeo( proxy: GeometryProxy, num: Int ) -> Double {
        let v = proxy.size.width - (proxy.size.width/10)*Double(num)
        return v < 0 ? 0 : v
    }
    
    func quadrantForTap( proxy: GeometryProxy, coords: CGPoint ) {
        
    }
    var offset = 10
    var body: some View {
        
        VStack {
            GeometryReader { geo in
                VStack
                {
                    ZStack {
                        ForEach((0...11), id: \.self) { num in
                            Circle()
                                .strokeBorder(bordercolors[num], lineWidth: lineWidth)
                                .background(Circle().fill(colors[num]))
                                .frame( width: widthFromGeo(proxy: geo, num: num),
                                        height: widthFromGeo(proxy: geo, num: num)  )
                        }
                        Circle().strokeBorder(.black, lineWidth: lineWidth/2)
                            .background(Circle().fill(colors.last!))
                            .frame(width: geo.size.width/10/2, height: geo.size.width/10/2)
                        Image(systemName: "plus").scaleEffect(0.3)
                        
                        MarkerView().offset(x: markerLocation.x - geo.size.width/2, y: markerLocation.y - geo.size.height/2 + CGFloat(offset)).zIndex(0)
                    }
                    .scaleEffect(scale, anchor: UnitPoint.topTrailing)
                    .gesture( SpatialTapGesture( count: 2, coordinateSpace: .local ).onEnded({ val in
                        print(val)
                        withAnimation {
                            scale = (scale == 2.0) ? 1.0 : 2.0
                        }
        
                    }))
                    
                }
                .frame(height: geo.size.width).padding(.bottom, 5)
            }
            GeometryReader { grd in
                TouchPadView()
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .updating($location) { (value, state, transaction) in
                            state = value.location
                            DispatchQueue.main.async {
                                markerLocation = CGPoint(x: value.location.x, y: value.location.y)
                            }
                            //
                            print("size: \(grd.size)")
                            print("loc: \(value.location)")
                        }.onEnded { val in
                            print("ENDED \(val)")
                        })
                    .offset(y:CGFloat(offset))
            }
        }
        
        
        
    }
}

struct TouchPadView : View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 24.0, style: .continuous).fill(.gray)
        }
    }
}
struct ContentView : View {
    var body: some View {
        VStack {
            TargetFaceView()
            //            TouchPadView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
