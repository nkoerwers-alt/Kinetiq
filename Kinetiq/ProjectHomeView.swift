
import SwiftUI

struct ProjectHomeView: View {
    @State private var activeProject: EditorProject?

    var body: some View {
        Group {
            if let project = activeProject {
                ContentView(project: project)
                    .onDisappear {
                        activeProject = nil
                    }
            } else {
                ProjectManagerView { project in
                    activeProject = project
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
