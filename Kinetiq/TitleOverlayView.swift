
import SwiftUI

struct TitleOverlayView: View {
    @Binding var title: String
    @Binding var fontSize: Double
    @Binding var textColor: Color
    @Binding var alignment: TextAlignment

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TEXT OVERLAY")
                .font(.system(size: 12, weight: .bold))
                .tracking(1)

            TextField("Enter your title", text: $title, axis: .vertical)
                .font(.system(size: 14))
                .padding(12)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .lineLimit(1...3)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Font size")
                    Spacer()
                    Text("\(Int(fontSize)) pt")
                        .monospacedDigit()
                }
                .font(.system(size: 12))

                Slider(value: $fontSize, in: 12...96, step: 2)
                    .tint(.blue)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Text color")
                    .font(.system(size: 12))

                HStack(spacing: 12) {
                    colorButton(.white)
                    colorButton(.yellow)
                    colorButton(.red)
                    colorButton(.green)
                    colorButton(.blue)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Alignment")
                    .font(.system(size: 12))

                HStack(spacing: 8) {
                    alignmentButton(.leading, symbol: "text.alignleft")
                    alignmentButton(.center, symbol: "text.aligncenter")
                    alignmentButton(.trailing, symbol: "text.alignright")
                }
            }

            VStack(spacing: 8) {
                Text(title.isEmpty ? "Title Preview" : title)
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(alignment)
                    .frame(maxWidth: .infinity, alignment: frameAlignment)
                    .padding(16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("Preview only. Rendering titles into exported video requires timeline integration.")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var frameAlignment: Alignment {
        switch alignment {
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }

    private func colorButton(_ color: Color) -> some View {
        Button {
            textColor = color
        } label: {
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
                .overlay {
                    Circle()
                        .stroke(
                            textColor == color ? .blue : .gray.opacity(0.4),
                            lineWidth: textColor == color ? 3 : 1
                        )
                }
        }
        .buttonStyle(.plain)
    }

    private func alignmentButton(
        _ value: TextAlignment,
        symbol: String
    ) -> some View {
        Button {
            alignment = value
        } label: {
            Image(systemName: symbol)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(
                    alignment == value
                        ? Color.blue.opacity(0.25)
                        : Color.white.opacity(0.06)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }
}
