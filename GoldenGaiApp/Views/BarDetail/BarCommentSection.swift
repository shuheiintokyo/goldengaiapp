import SwiftUI

struct BarCommentSection: View {
    let bar: Bar
    let comments: [BarComment]
    @State private var commentText = ""
    @State private var selectedLanguage: Language = .english
    @State private var isSubmitting = false
    @State private var submitError: String?
    
    var onAddComment: (String, Language) async throws -> Void = { _, _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comments")
                    .font(.headline)
                
                Spacer()
                
                Text("\(comments.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    TextField("Add a comment...", text: $commentText)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .frame(width: 80)
                    .pickerStyle(.menu)
                }
                
                Button(action: {
                    Task {
                        await submitComment()
                    }
                }) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Post")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(commentText.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)
                
                if let error = submitError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            if comments.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No comments yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(comments) { comment in
                        CommentRowView(comment: comment)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func submitComment() async {
        let trimmedText = commentText.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }
        
        isSubmitting = true
        submitError = nil
        
        do {
            try await onAddComment(trimmedText, selectedLanguage)
            commentText = ""
        } catch {
            submitError = error.localizedDescription
        }
        
        isSubmitting = false
    }
}

struct CommentRowView: View {
    let comment: BarComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(comment.author)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(comment.language.displayName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let rating = comment.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                    }
                }
            }
            
            Text(comment.content)
                .font(.caption)
                .lineLimit(3)
            
            Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
    }
}

