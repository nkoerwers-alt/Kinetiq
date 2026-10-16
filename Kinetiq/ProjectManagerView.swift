
import SwiftUI

struct ProjectManagerView: View {
    @State private var projects: [EditorProject] = []
    @State private var showingNewProject = false
    @State private var projectName = ""
    @State private var errorMessage: String?

    var onOpenProject: (EditorProject) -> Void = { _ in }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects",
                        systemImage: "film.stack",
                        description: Text("Create a project to start editing.")
                    )
                } else {
                    List {
                        ForEach(projects) { project in
                            Button {
                                onOpenProject(project)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "film")
                                        .font(.system(size: 20))
                                        .frame(width: 44, height: 44)
                                        .background(.white.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(project.name)
                                            .font(.system(size: 14, weight: .semibold))

                                        Text("\(project.clips.count) clips")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .foregroundStyle(.primary)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteProject(project)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kinetiq Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        projectName = ""
                        showingNewProject = true
                    } label: {
                        Label("New Project", systemImage: "plus")
                    }
                }
            }
            .alert("New Project", isPresented: $showingNewProject) {
                TextField("Project name", text: $projectName)

                Button("Cancel", role: .cancel) {}

                Button("Create") {
                    createProject()
                }
            } message: {
                Text("Choose a name for your project.")
            }
            .alert(
                "Project Error",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .onAppear {
                refreshProjects()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func refreshProjects() {
        do {
            projects = try ProjectStorage.list()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func createProject() {
        let name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            errorMessage = "Enter a project name."
            return
        }

        let project = EditorProject(name: name)

        do {
            try ProjectStorage.save(project)
            refreshProjects()
            onOpenProject(project)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteProject(_ project: EditorProject) {
        do {
            try ProjectStorage.delete(id: project.id)
            refreshProjects()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
