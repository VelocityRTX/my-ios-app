//
//  SupportResourcesView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct SupportResourcesView: View {
    @State private var selectedResourceType: ResourceType = .hotlines
    
    enum ResourceType: String, CaseIterable {
        case hotlines = "Hotlines"
        case online = "Online"
        case local = "Local"
        case emergency = "Emergency"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Resource type selector
            Picker("Resource Type", selection: $selectedResourceType) {
                ForEach(ResourceType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Resources list
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(filteredResources, id: \.name) { resource in
                        ResourceCardView(resource: resource)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Support Resources")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Filter resources based on selected type
    private var filteredResources: [SupportResource] {
        supportResources.filter { $0.type == selectedResourceType }
    }
}

// Resource card view
struct ResourceCardView: View {
    let resource: SupportResource
    @State private var isShowingAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(resource.name)
                    .font(.headline)
                
                Spacer()
                
                if resource.isConfidential {
                    Label("Confidential", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text(resource.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Contact methods
            VStack(spacing: 10) {
                if let phone = resource.phone {
                    Button(action: {
                        let phoneURL = URL(string: "tel:\(phone.filter { $0.isNumber })")!
                        if UIApplication.shared.canOpenURL(phoneURL) {
                            UIApplication.shared.open(phoneURL)
                        }
                    }) {
                        Label(phone, systemImage: "phone.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                if let website = resource.website {
                    Button(action: {
                        if let url = URL(string: website) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Visit Website", systemImage: "globe")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                if let textNumber = resource.textNumber {
                    Button(action: {
                        let smsURL = URL(string: "sms:\(textNumber)")!
                        if UIApplication.shared.canOpenURL(smsURL) {
                            UIApplication.shared.open(smsURL)
                        }
                    }) {
                        Label("Text \(resource.textKeyword ?? textNumber)", systemImage: "message.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Hours
            if let hours = resource.hours {
                Text("Hours: \(hours)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Privacy note
            if resource.isConfidential {
                HStack {
                    Image(systemName: "shield.checkerboard")
                        .foregroundColor(.green)
                    
                    Text("All contacts are confidential")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("External Link"),
                message: Text("This will open an external service. Continue?"),
                primaryButton: .default(Text("Continue")) {
                    if let website = resource.website, let url = URL(string: website) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

// Support resource model
struct SupportResource {
    let name: String
    let description: String
    let type: SupportResourcesView.ResourceType
    let phone: String?
    let textNumber: String?
    let textKeyword: String?
    let website: String?
    let hours: String?
    let isConfidential: Bool
}

// Sample support resources
let supportResources: [SupportResource] = [
    // Hotlines
    SupportResource(
        name: "Truth Initiative Quit Line",
        description: "Free and confidential phone, text, and chat coaching for quitting vaping and smoking.",
        type: .hotlines,
        phone: "1-855-891-9989",
        textNumber: "88709",
        textKeyword: "DITCHJUUL",
        website: "https://truthinitiative.org/thisisquitting",
        hours: "24/7",
        isConfidential: true
    ),
    
    SupportResource(
        name: "National Quitline",
        description: "Free coaching, resources, and support to help you quit vaping or smoking.",
        type: .hotlines,
        phone: "1-800-QUIT-NOW (1-800-784-8669)",
        textNumber: nil,
        textKeyword: nil,
        website: "https://smokefree.gov",
        hours: "24/7",
        isConfidential: true
    ),
    
    // Online resources
    SupportResource(
        name: "This Is Quitting",
        description: "A free mobile program from Truth Initiative designed to help young people quit vaping.",
        type: .online,
        phone: nil,
        textNumber: "88709",
        textKeyword: "DITCHVAPE",
        website: "https://truthinitiative.org/thisisquitting",
        hours: "24/7",
        isConfidential: true
    ),
    
    SupportResource(
        name: "Smokefree Teen",
        description: "Website with resources specifically for teens who want to quit vaping or smoking.",
        type: .online,
        phone: nil,
        textNumber: nil,
        textKeyword: nil,
        website: "https://teen.smokefree.gov",
        hours: "24/7",
        isConfidential: true
    ),
    
    // Local resources (these would be customized based on location)
    SupportResource(
        name: "School Counseling Services",
        description: "Your school counselor can provide confidential support and resources.",
        type: .local,
        phone: nil,
        textNumber: nil,
        textKeyword: nil,
        website: nil,
        hours: "School hours",
        isConfidential: true
    ),
    
    SupportResource(
        name: "Community Health Centers",
        description: "Local health centers often offer free or low-cost support for quitting.",
        type: .local,
        phone: nil,
        textNumber: nil,
        textKeyword: nil,
        website: "https://findahealthcenter.hrsa.gov",
        hours: "Varies by location",
        isConfidential: true
    ),
    
    // Emergency resources
    SupportResource(
        name: "Crisis Text Line",
        description: "Free, 24/7 support for people in crisis. Text for help with anxiety, depression, and more.",
        type: .emergency,
        phone: nil,
        textNumber: "741741",
        textKeyword: "HOME",
        website: "https://www.crisistextline.org",
        hours: "24/7",
        isConfidential: true
    ),
    
    SupportResource(
        name: "988 Suicide & Crisis Lifeline",
        description: "If you're having thoughts of self-harm or experiencing a mental health crisis.",
        type: .emergency,
        phone: "988",
        textNumber: "988",
        textKeyword: nil,
        website: "https://988lifeline.org",
        hours: "24/7",
        isConfidential: true
    )
]
