//
//  ContentView.swift
//  FoodPicker
//
//  Created by Amigo Lu on 2025/11/26.
//

import SwiftUI

struct ContentView: View {
    
    let food = Food.examples
    
    @State private var selectFood: Food?
    @State private var shouldShowInfo = false
 
    
    var body: some View {
        ScrollView{
            VStack(spacing:20) {
     
                foodImage
                
                Text("今天吃什麼")
                    .font(.largeTitle)
                    .bold()
                
                foodInfoView
                
                Spacer()
                
                Button(role: .none) {
                    selectFood = food.shuffled().first { $0 != selectFood }
                    
                } label: {
                    Text(selectFood == .none ? "TellME" : "Change other").frame(width:200)
                }.font(.largeTitle)
                    .buttonStyle(.borderedProminent)
                
                Button {
                    selectFood = .none
                }label: {
                    Text("重置").frame(width: 200)
                }.buttonStyle(.bordered)
                
                
            }
            .frame(maxHeight: .infinity)
            .animation(.none, value: selectFood) //動畫產生
            .animation(.spring(dampingFraction:0.3), value: shouldShowInfo)
            //.transformEffect(.identity)
            //.transition(.asymmetric(insertion: .scale, removal: .scale))
            //.background(Color(.secondarySystemBackground))
            .font(.title)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
    }
    
    var foodImage: some View{
        Group {
            if selectFood != .none {
                Text(selectFood!.image)
                    .font(.system(size: 200))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
            } else {
                Image("food_1")
                    .renderingMode(/*@START_MENU_TOKEN@*/.original/*@END_MENU_TOKEN@*/)
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                    .padding(.horizontal)
            }
        }.frame(height:250)
    }

    @ViewBuilder var foodInfoView: some View{
        HStack {
            if selectFood != .none {
                Text(selectFood!.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.green)
                    .id(selectFood!.name)
                    //.transition(.asymmetric(insertion: .scale, removal: .scale))
                    .frame(width: 200)
                    .background(.red)
                
                Button {
                    shouldShowInfo.toggle()
                    
                    
                } label: {
                    Image(systemName: "questionmark.circle.fill") // 使用填充的問號圖標
                        .font(.title3)
                    
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal) // 讓 HStack 兩側有一些邊距
        
        if selectFood != .none {
            
                Text("熱量 \(selectFood!.calorie.formatted()) 大卡")
                    .font(.largeTitle)
                    .id(selectFood!.calorie)
                
            if shouldShowInfo {
                HStack {
                    VStack(spacing:12){
                        Text("蛋白質")
                        Text(selectFood!.protein.formatted() + " g")
                    }
                    
                    Divider().frame(width:1).padding(.horizontal)
                    VStack(spacing:12){
                        Text("脂肪")
                        Text(selectFood!.fat.formatted() + " g")
                    }
                    Divider().frame(width:1).padding(.horizontal)
                    VStack(spacing:12){
                        Text("碳水")
                        Text(selectFood!.carb.formatted() + " g")
                    }
                }
            }
        }
    }


}

#Preview {
    ContentView()
}

