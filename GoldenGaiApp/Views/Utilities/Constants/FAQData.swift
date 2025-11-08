import Foundation

struct FAQData {
    struct Question {
        let question: String
        let answer: String
    }
    
    static let faqItems: [Question] = [
        Question(
            question: "How do I add a bar?",
            answer: "You can view bars in the list. To mark a bar as visited, tap the checkmark icon."
        ),
        Question(
            question: "Can I upload photos?",
            answer: "Yes, you can upload photos when viewing bar details. Tap the photo section to add images."
        ),
        Question(
            question: "How does sync work?",
            answer: "The app automatically syncs with the cloud. You can also manually sync from settings."
        ),
        Question(
            question: "Is my data private?",
            answer: "Yes, your data is encrypted and stored securely. See our privacy policy for more details."
        )
    ]
}
