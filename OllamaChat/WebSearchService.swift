import Foundation

struct SearchResult {
    let title: String
    let url: String
    let snippet: String
}

class WebSearchService {
    // Using DuckDuckGo Instant Answer API (free, no API key required)
    // For production, consider using Google Custom Search, Bing, or SerpAPI
    func search(query: String) async -> [SearchResult] {
        // URL encode the query
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.duckduckgo.com/?q=\(encodedQuery)&format=json&no_html=1&skip_disambig=1") else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Parse DuckDuckGo response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                var results: [SearchResult] = []
                
                // Get abstract (if available)
                if let abstract = json["Abstract"] as? String,
                   let abstractURL = json["AbstractURL"] as? String,
                   !abstract.isEmpty {
                    results.append(SearchResult(
                        title: json["AbstractText"] as? String ?? "Abstract",
                        url: abstractURL,
                        snippet: abstract
                    ))
                }
                
                // Get related topics
                if let relatedTopics = json["RelatedTopics"] as? [[String: Any]] {
                    for topic in relatedTopics.prefix(5) {
                        if let text = topic["Text"] as? String,
                           let firstURL = topic["FirstURL"] as? String {
                            results.append(SearchResult(
                                title: topic["FirstURL"] as? String ?? "Result",
                                url: firstURL,
                                snippet: text
                            ))
                        }
                    }
                }
                
                // Get results from Answer
                if let answer = json["Answer"] as? String,
                   let answerURL = json["AnswerURL"] as? String,
                   !answer.isEmpty {
                    results.append(SearchResult(
                        title: "Answer",
                        url: answerURL,
                        snippet: answer
                    ))
                }
                
                return results
            }
        } catch {
            print("Search error: \(error)")
        }
        
        return []
    }
    
    // Alternative: Use a simple web scraping approach for better results
    // Note: This is a basic implementation. For production, use a proper search API
    func searchWithBing(query: String, apiKey: String) async -> [SearchResult] {
        // This would require a Bing Search API key
        // Implementation would go here if you have an API key
        return []
    }
}

