import SwiftUI
@preconcurrency import WebKit

struct ContentView: View {
    @State private var selectedURL: URL? = nil
    @State private var hoveredLink: String? = nil

    // Gruvbox color scheme
    struct GruvboxColors {
        static let bg = Color(red: 40/255, green: 40/255, blue: 40/255)
        static let bg0 = Color(red: 29/255, green: 32/255, blue: 33/255)
        static let fg = Color(red: 235/255, green: 219/255, blue: 178/255)
        static let yellow = Color(red: 250/255, green: 189/255, blue: 47/255)
        static let orange = Color(red: 254/255, green: 128/255, blue: 25/255)
        static let red = Color(red: 251/255, green: 73/255, blue: 52/255)
        static let green = Color(red: 184/255, green: 187/255, blue: 38/255)
        static let aqua = Color(red: 142/255, green: 192/255, blue: 124/255)
        static let blue = Color(red: 131/255, green: 165/255, blue: 152/255)
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack(spacing: 20) {
                    Text("Srijit Dey")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(GruvboxColors.orange)
                        .padding(.top, 30)
                        .padding(.bottom, 5)

                    Text("I'm a passionate developer from India, currently diving deep into the world of web development.")
                        .font(.system(size: 16))
                        .foregroundColor(GruvboxColors.fg)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(icon: "globe", text: "Location: India")
                        InfoRow(icon: "book.fill", text: "Learning: MERN Stack")
                        InfoRow(icon: "laptopcomputer", text: "Interests: Full-stack Development")
                    }
                    .padding(.vertical)

                    Divider()
                        .background(GruvboxColors.yellow.opacity(0.3))
                        .padding(.vertical)

                    Text("Projects")
                        .font(.headline)
                        .foregroundColor(GruvboxColors.orange)
                        .padding(.bottom, 10)

                    VStack(spacing: 12) {
                        ForEach(links, id: \.url) { link in
                            Button(action: {
                                selectedURL = URL(string: link.url)
                            }) {
                                Text(link.title)
                                    .foregroundColor(hoveredLink == link.url ? GruvboxColors.yellow : GruvboxColors.aqua)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(hoveredLink == link.url ? GruvboxColors.bg0 : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(hoveredLink == link.url ? GruvboxColors.yellow.opacity(0.5) : Color.clear, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onHover { isHovered in
                                hoveredLink = isHovered ? link.url : nil
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    HStack(spacing: 20) {
                        SocialButton(text: "LinkedIn", url: "https://www.linkedin.com/in/zeropse")
                        SocialButton(text: "GitHub", url: "https://github.com/zeropse")
                        SocialButton(text: "X", url: "https://x.com/zer0pse")
                    }
                    .padding(.bottom, 20)
                }
                .frame(width: 300)
                .background(GruvboxColors.bg0)
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(GruvboxColors.fg.opacity(0.1)),
                    alignment: .trailing
                )

                ZStack {
                    if let url = selectedURL {
                        WebView(url: url)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "globe")
                                .font(.system(size: 40))
                                .foregroundColor(GruvboxColors.fg.opacity(0.3))
                            Text("Select a project to view")
                                .font(.system(size: 18))
                                .foregroundColor(GruvboxColors.fg.opacity(0.5))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GruvboxColors.bg)
            }
            .frame(minWidth: 1200, maxWidth: .infinity, minHeight: 900, maxHeight: .infinity)
        }
        .onAppear {
            DispatchQueue.main.async {
                if let window = NSApp.windows.first {
                    window.setContentSize(NSSize(width: 1024, height: 768))
                    window.center()
                }
            }
        }
    }

    var links: [LinkItem] {
        [
            LinkItem(title: "Portfolio", url: "https://zeropse.xyz/"),
            LinkItem(title: "Valopedia", url: "https://valopedia-nine.vercel.app/"),
            LinkItem(title: "KnightBot", url: "https://github.com/zeropse/KnightBot")
        ]
    }
}

// WebView implementation
struct WebView: NSViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Set the delegate of the WKWebView to handle link clicks
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let targetURL = navigationAction.request.url, navigationAction.targetFrame == nil {
                // If the targetFrame is nil, it indicates that the link is trying to open in a new window (like _blank)
                // Open it in the default web browser
                NSWorkspace.shared.open(targetURL)
                decisionHandler(.cancel) // Prevent WKWebView from loading the URL internally
            } else {
                // Otherwise, allow WKWebView to load the URL internally
                decisionHandler(.allow)
            }
        }
    }
}

struct SocialButton: View {
    let text: String
    let url: String
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                NSWorkspace.shared.open(url)
            }
        }) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isHovered ? ContentView.GruvboxColors.yellow : ContentView.GruvboxColors.fg)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isHovered ? ContentView.GruvboxColors.bg0 : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHovered ? ContentView.GruvboxColors.yellow.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ContentView.GruvboxColors.yellow)
            Text(text)
                .foregroundColor(ContentView.GruvboxColors.fg)
        }
    }
}

struct LinkItem: Hashable {
    let title: String
    let url: String
}
