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

enum Corner {
    case topleft
    case topright
    case bottomleft
    case bottomright
}

struct TargetFaceView: View {
    @GestureState private var location: CGPoint = .zero
    @State var markerLocation : CGPoint = .zero
    var lineWidth = 0.5
    var colors : [Color] = [ .white, .white, .black, .black, .blue, .blue, .red, .red, .yellow, .yellow, .yellow]
    var bordercolors : [Color] = [ .black, .black, .black, .white, .black, .black, .black, .black, .black, .black, .black]
    @State var scale = 1.0
    
    func targetWidth( proxy: GeometryProxy ) -> Double {
        return min(proxy.frame(in: .local).width, UIScreen.main.bounds.height/2)
    }
    
    func widthFromGeo( proxy: GeometryProxy, num: Int ) -> Double {
        let v = targetWidth(proxy: proxy) - targetWidth(proxy:proxy)/10*Double(num)
        return v < 0 ? 0 : v
    }
    
    func quadrantForTap( proxy: GeometryProxy, coords: CGPoint ) -> Corner {
        
        return .topright
    }
    var offset = 10
    var body: some View {
        VStack(spacing:0) {
            GeometryReader { geo in
                VStack(spacing: 0)
                {
                    ZStack {
                        ForEach((0..<11), id: \.self) { num in
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
                        
                        MarkerView().offset(x: markerLocation.x - geo.size.width/2, y: markerLocation.y - geo.size.height/2 + CGFloat(offset)).zIndex(0).scaleEffect(1/scale)
                    }
                    .scaleEffect(scale, anchor: UnitPoint.topTrailing)
                    .gesture( SpatialTapGesture( count: 2, coordinateSpace: .local ).onEnded({ val in
                        print(val)
                        withAnimation {
                            scale = (scale == 2.0) ? 1.0 : 2.0
                        }
        
                    }))
                    .gesture(MagnificationGesture()
                        .onChanged({ scale in
                        print("changed scale \(scale)")
                    })
                        .onEnded({ scaled in
                        print("ended scale: \(scaled)")
                    }))
                    
                
                    
                }.position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
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
//                    .offset(y:CGFloat(offset))
//                    .frame(height: UIScreen.main.bounds.size.height/3)
            }
        }
        
        
        
    }
}

struct TouchPadView : View {
    var body: some View {
        VStack(spacing:0) {
            ZStack {
                Rectangle().fill(Color("Touchpad"))
                RoundedRectangle(cornerRadius: 24.0, style: .continuous)
                    .foregroundStyle(
                        Color("Touchpad").gradient
                            .shadow(.inner(color: .white.opacity(0.3), radius: 1, x: 1, y: 1))
                            .shadow(.inner(radius: 1, x: 2, y: 2))
                    )            }
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
