
import SwiftUI

struct EditorToolButton: View {
    let title: String
    let symbol: String
    var isSelected = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .medium))

                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.white.opacity(0.12) : .clear)
            }
        }
        .buttonStyle(.plain)
    }
}

struct TimelineClipView: View {
    let title: String
    let color: Color
    var isSelected = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)

            Spacer(minLength: 0)

            HStack(spacing: 3) {
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(index.isMultiple(of: 2) ? 0.28 : 0.12))
                        .frame(height: CGFloat(12 + (index % 3) * 7))
                }
            }
        }
        .foregroundStyle(.white)
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
        .background(color.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? .white : .clear, lineWidth: 2)
        }
    }
}

struct TimelineTrackRow: View {
    let name: String
    let symbol: String
    let color: Color
    let clipTitle: String
    var isSelected = false

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .frame(width: 16)

                Text(name)
                    .lineLimit(1)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.7))
            .frame(width: 100, alignment: .leading)

            TimelineClipView(
                title: clipTitle,
                color: color,
                isSelected: isSelected
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }
}

struct PreviewPlaceholder: View {
    let isPlaying: Bool

    var body: some View {
        ZStack {
            Color(red: 0.055, green: 0.055, blue: 0.065)

            VStack(spacing: 12) {
                Image(systemName: "film")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(.white.opacity(0.55))

                Text("Preview")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))

                Text(isPlaying ? "Playback preview" : "Import media to begin")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
