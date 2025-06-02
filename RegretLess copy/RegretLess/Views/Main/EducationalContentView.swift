//
//  EducationalContentView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct EducationalContentView: View {
    @State private var selectedCategory: ContentCategory = .basics
    @State private var searchText = ""
    
    enum ContentCategory: String, CaseIterable {
        case basics = "Basics"
        case health = "Health Effects"
        case quitting = "Quitting"
        case science = "The Science"
        case resources = "Resources"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(ContentCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.theme.accent : Color.theme.secondaryBackground)
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search articles...", text: $searchText)
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color.theme.secondaryBackground)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Content list
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(filteredArticles, id: \.title) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleRowView(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Learn About Vaping")
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
    }
    
    // Filter articles based on category and search text
    private var filteredArticles: [EducationalArticle] {
        var articles = educationalArticles.filter { $0.category == selectedCategory }
        
        if !searchText.isEmpty {
            articles = articles.filter { article in
                article.title.lowercased().contains(searchText.lowercased()) ||
                article.summary.lowercased().contains(searchText.lowercased())
            }
        }
        
        return articles
    }
}

// Article row view
struct ArticleRowView: View {
    let article: EducationalArticle
    
    var body: some View {
        HStack(spacing: 15) {
            // Article image
            Image(systemName: article.iconName)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(article.accentColor)
                .cornerRadius(10)
            
            // Article details
            VStack(alignment: .leading, spacing: 5) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(article.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("\(article.readTimeMinutes) min read")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if article.isVerified {
                        Label("Expert Verified", systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Article detail view
struct ArticleDetailView: View {
    @EnvironmentObject var userStore: UserStore
    let article: EducationalArticle
    @State private var hasEarnedPoints = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Article header
                VStack(alignment: .leading, spacing: 10) {
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("\(article.readTimeMinutes) min read")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if article.isVerified {
                            Spacer()
                            
                            Label("Expert Verified", systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Article image
                HStack {
                    Spacer()
                    
                    Image(systemName: article.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 120)
                        .background(article.accentColor)
                        .cornerRadius(15)
                    
                    Spacer()
                }
                .padding(.vertical)
                
                // Article content
                ForEach(article.content, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 15) {
                        Text(section.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(section.content)
                            .lineSpacing(5)
                        
                        if let bulletPoints = section.bulletPoints {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(bulletPoints, id: \.self) { point in
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .fontWeight(.bold)
                                        
                                        Text(point)
                                    }
                                }
                            }
                            .padding(.leading, 5)
                        }
                    }
                    .padding(.bottom, 15)
                }
                
                // Sources section
                if !article.sources.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sources")
                            .font(.headline)
                        
                        ForEach(article.sources, id: \.self) { source in
                            Text(source)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(10)
                }
                
                // Claim points button
                if !hasEarnedPoints {
                    Button(action: {
                        userStore.awardPoints(amount: 10, reason: .appUsage, description: "Learning about vaping")
                        hasEarnedPoints = true
                    }) {
                        Label("Claim 10 Learning Points", systemImage: "star.fill")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.accent)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Educational article model
struct EducationalArticle {
    let title: String
    let summary: String
    let category: EducationalContentView.ContentCategory
    let content: [ArticleSection]
    let readTimeMinutes: Int
    let isVerified: Bool
    let iconName: String
    let accentColor: Color
    let sources: [String]
}

// Article section model
struct ArticleSection {
    let title: String
    let content: String
    let bulletPoints: [String]?
    
    init(title: String, content: String, bulletPoints: [String]? = nil) {
        self.title = title
        self.content = content
        self.bulletPoints = bulletPoints
    }
}

// Sample educational content
let educationalArticles: [EducationalArticle] = [
    // Basics category articles
    EducationalArticle(
        title: "What is Vaping?",
        summary: "A basic introduction to vaping, e-cigarettes, and how they work.",
        category: .basics,
        content: [
            ArticleSection(
                title: "What are E-cigarettes?",
                content: "Electronic cigarettes (e-cigarettes) are devices that deliver nicotine, flavorings, and other additives to the user through an inhaled aerosol. These devices are known by many different names, including 'e-cigs,' 'e-hookahs,' 'mods,' 'vape pens,' 'vapes,' 'tank systems,' and 'electronic nicotine delivery systems (ENDS).'"
            ),
            ArticleSection(
                title: "How Do E-cigarettes Work?",
                content: "Most e-cigarettes consist of a battery, a heating element, and a place to hold a liquid. The liquid typically contains nicotine, flavorings, and other chemicals. When you inhale, the device heats up the liquid, turning it into an aerosol (vapor) that you breathe in.",
                bulletPoints: [
                    "A battery powers the device",
                    "A heating element (atomizer) turns liquid into aerosol",
                    "A cartridge or tank holds the e-liquid",
                    "A mouthpiece is used to inhale"
                ]
            ),
            ArticleSection(
                title: "Types of E-cigarettes",
                content: "There are many different types of e-cigarettes on the market, from disposable pens to refillable tanks. Some look like USB flash drives or pens, which make them easy to hide. Others are larger and have customizable features."
            )
        ],
        readTimeMinutes: 5,
        isVerified: true,
        iconName: "cloud.fill",
        accentColor: Color.theme.blue,
        sources: [
            "Centers for Disease Control and Prevention. (2023). About Electronic Cigarettes.",
            "National Institute on Drug Abuse. (2023). Electronic Cigarettes (E-cigarettes)."
        ]
    ),
    
    EducationalArticle(
        title: "Nicotine and Addiction",
        summary: "Understanding nicotine, how it affects the brain, and why it's addictive.",
        category: .basics,
        content: [
            ArticleSection(
                title: "What is Nicotine?",
                content: "Nicotine is a highly addictive chemical compound present in tobacco plants and is the primary addictive substance in vaping products. When inhaled, nicotine is rapidly absorbed into the bloodstream and reaches the brain within seconds."
            ),
            ArticleSection(
                title: "How Nicotine Affects the Brain",
                content: "When nicotine enters the brain, it triggers the release of neurotransmitters like dopamine, which creates feelings of pleasure and reward. This is what makes nicotine so addictive - your brain quickly learns to associate vaping with these good feelings and craves more.",
                bulletPoints: [
                    "Stimulates release of dopamine (the 'feel-good' chemical)",
                    "Increases adrenaline, raising heart rate and blood pressure",
                    "Affects parts of the brain involved in attention and memory"
                ]
            ),
            ArticleSection(
                title: "Nicotine and the Teenage Brain",
                content: "The teenage brain is still developing, making it especially vulnerable to nicotine's effects. Using nicotine during adolescence can harm the parts of the brain that control attention, learning, mood, and impulse control. It can also prime the brain for addiction to other substances."
            ),
            ArticleSection(
                title: "Signs of Nicotine Addiction",
                content: "You might be addicted to nicotine if you experience cravings, find it hard to go without vaping, need to vape more to get the same effect (tolerance), or experience withdrawal symptoms when you try to quit.",
                bulletPoints: [
                    "Strong urges or cravings to vape",
                    "Irritability, anxiety, or difficulty concentrating when not vaping",
                    "Failed attempts to cut down or quit",
                    "Needing to vape more frequently or in larger amounts"
                ]
            )
        ],
        readTimeMinutes: 7,
        isVerified: true,
        iconName: "brain.head.profile",
        accentColor: Color.theme.purple,
        sources: [
            "National Institute on Drug Abuse. (2023). Nicotine and the Brain.",
            "Surgeon General's Report on E-cigarette Use Among Youth and Young Adults. (2022)."
        ]
    ),
    
    // Health Effects category articles
    EducationalArticle(
        title: "Vaping and Your Lungs",
        summary: "How vaping affects your lung health and respiratory system.",
        category: .health,
        content: [
            ArticleSection(
                title: "What Enters Your Lungs When You Vape",
                content: "When you vape, your lungs are exposed to a mixture of chemicals, many of which can be harmful. This aerosol isn't just 'harmless water vapor' as some might claim. It contains nicotine, ultrafine particles, flavoring chemicals, volatile organic compounds, and heavy metals like lead."
            ),
            ArticleSection(
                title: "Short-Term Effects on Lungs",
                content: "Even in the short term, vaping can irritate your lungs and cause inflammation. Many vapers report symptoms like coughing, chest pain, shortness of breath, and increased mucus production.",
                bulletPoints: [
                    "Irritation of the airways",
                    "Inflammation in lung tissue",
                    "Increased susceptibility to respiratory infections",
                    "Reduced lung function during physical activity"
                ]
            ),
            ArticleSection(
                title: "Long-Term Concerns",
                content: "Because vaping is relatively new, scientists are still studying the long-term effects. However, early research suggests potential serious consequences, including chronic bronchitis, emphysema, and increased risk of lung diseases."
            ),
            ArticleSection(
                title: "EVALI: E-cigarette or Vaping Product Use-Associated Lung Injury",
                content: "In 2019-2020, there was an outbreak of serious lung injuries associated with vaping products. Symptoms included respiratory issues, abdominal pain, nausea, vomiting, diarrhea, fever, chills, and weight loss. Many people were hospitalized, and some died from this condition."
            )
        ],
        readTimeMinutes: 8,
        isVerified: true,
        iconName: "lungs.fill",
        accentColor: Color.theme.red,
        sources: [
            "American Lung Association. (2023). The Impact of E-cigarettes on the Lungs.",
            "Centers for Disease Control and Prevention. (2023). Outbreak of Lung Injury Associated with E-cigarette Use.",
            "Johns Hopkins Medicine. (2023). 5 Vaping Facts You Need to Know."
        ]
    ),
    
    // Quitting category articles
    EducationalArticle(
        title: "Strategies for Quitting",
        summary: "Effective approaches and methods to help you quit vaping successfully.",
        category: .quitting,
        content: [
            ArticleSection(
                title: "Why It's Hard to Quit",
                content: "Quitting vaping is challenging because nicotine causes both physical dependence and psychological addiction. Your body has become accustomed to nicotine, and your brain associates vaping with pleasure, stress relief, or social situations."
            ),
            ArticleSection(
                title: "Preparing to Quit",
                content: "Before you try to quit, it helps to prepare. Identify your triggers - the situations, feelings, or activities that make you want to vape. Then, plan how you'll handle those triggers differently.",
                bulletPoints: [
                    "Set a quit date",
                    "Tell friends and family for support",
                    "Remove vaping devices and products from your environment",
                    "Identify your personal reasons for quitting",
                    "Track your usage patterns to understand your triggers"
                ]
            ),
            ArticleSection(
                title: "Quitting Approaches",
                content: "There are different ways to quit vaping. Some people prefer to quit 'cold turkey' (all at once), while others find it easier to gradually reduce their usage over time. Both approaches can work - choose what feels right for you."
            ),
            ArticleSection(
                title: "Coping with Withdrawal",
                content: "When you quit, you may experience withdrawal symptoms like irritability, anxiety, difficulty concentrating, increased appetite, and intense cravings. These symptoms are temporary and typically peak within a few days to a week.",
                bulletPoints: [
                    "Stay hydrated and eat healthy foods",
                    "Exercise to reduce cravings and improve mood",
                    "Practice deep breathing or meditation",
                    "Use the distraction techniques in this app",
                    "Reach out for support when cravings hit"
                ]
            ),
            ArticleSection(
                title: "Handling Relapses",
                content: "Many people make several attempts before quitting for good. If you slip up, don't be too hard on yourself. Learn from what triggered the relapse, adjust your plan, and try again. Each attempt teaches you something valuable about your addiction and recovery process."
            )
        ],
        readTimeMinutes: 10,
        isVerified: true,
        iconName: "chart.line.uptrend.xyaxis",
        accentColor: Color.theme.green,
        sources: [
            "Truth Initiative. (2023). How to Quit Vaping.",
            "National Cancer Institute. (2023). How to Handle Withdrawal Symptoms and Triggers When You Decide to Quit.",
            "Mayo Clinic. (2023). Quitting Smoking: 10 Ways to Resist Tobacco Cravings."
        ]
    ),
    
    // Science category articles
    EducationalArticle(
        title: "The Science of Habit Formation",
        summary: "Understanding how habits form in the brain and how to create healthy new patterns.",
        category: .science,
        content: [
            ArticleSection(
                title: "The Habit Loop",
                content: "Habits follow a predictable pattern called the 'habit loop,' which consists of three components: a cue (trigger), a routine (the behavior itself), and a reward (the benefit you get from the behavior). Understanding this loop is key to changing habits."
            ),
            ArticleSection(
                title: "How Vaping Becomes a Habit",
                content: "Vaping delivers nicotine, which triggers the release of dopamine in the brain's reward center. This creates a powerful chemical reinforcement for the behavior. Over time, your brain creates strong neural pathways associating vaping with pleasure or relief.",
                bulletPoints: [
                    "Cue: Stress, boredom, social situations",
                    "Routine: Vaping",
                    "Reward: Nicotine-induced dopamine rush, relief from withdrawal"
                ]
            ),
            ArticleSection(
                title: "The Role of Neural Pathways",
                content: "When you repeat a behavior like vaping, your brain creates stronger and stronger neural connections associated with that behavior. Eventually, these pathways become so established that the behavior becomes automatic - something you do without conscious thought."
            ),
            ArticleSection(
                title: "Changing Habits: The Science",
                content: "Research shows that the most effective way to change a habit is not to try to eliminate it, but to replace it with a new one. You keep the same cue and reward, but change the routine in between. This is called 'habit substitution.'"
            ),
            ArticleSection(
                title: "The Importance of Repetition",
                content: "Creating new neural pathways requires repetition. The old saying that it takes 21 days to form a habit isn't quite accurate - research suggests it can take anywhere from 18 to 254 days, with an average of 66 days, for a new habit to become automatic. The important thing is to be consistent and patient."
            )
        ],
        readTimeMinutes: 9,
        isVerified: true,
        iconName: "brain",
        accentColor: Color.theme.mauve,
        sources: [
            "Duhigg, C. (2012). The Power of Habit: Why We Do What We Do in Life and Business.",
            "Clear, J. (2018). Atomic Habits: An Easy & Proven Way to Build Good Habits & Break Bad Ones.",
            "Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). How are habits formed: Modelling habit formation in the real world. European Journal of Social Psychology."
        ]
    ),
    
    // Resources category articles
    EducationalArticle(
        title: "Finding Support",
        summary: "Resources and support systems to help you on your journey to quit vaping.",
        category: .resources,
        content: [
            ArticleSection(
                title: "Why Support Matters",
                content: "Research consistently shows that people who have support are more successful at quitting than those who try to quit alone. Having support can provide encouragement, accountability, and practical help when cravings and challenges arise."
            ),
            ArticleSection(
                title: "Types of Support",
                content: "There are many different types of support available, from professional counseling to peer support groups to apps like this one. Different types of support work better for different people, so it's worth exploring several options.",
                bulletPoints: [
                    "Individual counseling",
                    "Support groups (in-person or online)",
                    "Text message programs",
                    "Quitlines (phone counseling)",
                    "Mobile apps",
                    "Friends and family"
                ]
            ),
            ArticleSection(
                title: "National Resources",
                content: "There are several national programs specifically designed to help teens and young adults quit vaping:"
            ),
            ArticleSection(
                title: "How to Ask for Help",
                content: "It can be hard to ask for help, especially if you've been hiding your vaping. Remember that healthcare providers, counselors, and support line staff are there to help, not judge. Be honest about your usage and challenges - this helps them provide the most effective support."
            ),
            ArticleSection(
                            title: "Supporting Someone Else",
                            content: "If you're supporting someone who's trying to quit, be patient and positive. Celebrate their successes, offer encouragement during setbacks, and help them find distractions when cravings hit. Avoid criticism or judgment if they slip up."
                        )
                    ],
                    readTimeMinutes: 6,
                    isVerified: true,
                    iconName: "person.2.fill",
                    accentColor: Color.theme.orange,
                    sources: [
                        "Truth Initiative. (2023). Getting Support for Quitting.",
                        "American Lung Association. (2023). How to Help Someone Quit.",
                        "National Cancer Institute. (2023). Where To Get Help When You Decide To Quit Smoking."
                    ]
                )
            ]
